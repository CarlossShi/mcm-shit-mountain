import numpy as np

import torch
from torch.nn.utils.rnn import pad_sequence
from torch.utils.data import Dataset


def icd2i(icd):
    i, c, d = icd.split(':')
    return i


def seq2itemID(sequence):
    """
    :param sequence: {str}, e.g. '133679233276:0:0;133658338671:0:0;133677846615:0:0'
    :return:
    """
    return {icd2i(icd) for icd in sequence.split(';')}


def icd2dict(icd):
    i, c, d = icd.split(':')
    return {'itemID': i, 'clicked': bool(eval(c)), 'duration': eval(d)}


class Sequence:
    def __init__(self, sequence):
        """
        :param sequence: {str}, e.g. '133679233276:0:0;133658338671:0:0;133677846615:0:0'
        :return:
        """
        self.sequence = [icd2dict(icd) for icd in sequence.split(';')]
        self.length = len(self.sequence)
        self.avg_clicked = np.mean([_['clicked'] for _ in self.sequence])
        self.sum_duration = np.sum([_['duration'] for _ in self.sequence])
        self.avg_duration = self.sum_duration / self.length
    def __len__(self):
        return self.length


class TrainDataset(Dataset):
    def __init__(self, df, userID2idx, itemID2idx):
        self.length = len(df)

        self.userID2idx = userID2idx
        self.itemID2idx = itemID2idx

        self.userLen = len(userID2idx)
        self.itemLen = len(itemID2idx)

        self.userID, self.requestID = df['userID'], df['requestID']  # string
        self.userIdx = torch.tensor([userID2idx[_] for _ in self.userID], dtype=torch.int32)  # {Tensor: (len(df),)}

        # self.date = torch.tensor(df.astype({'date': 'int32'})['date'])  # e.g. 20220106
        # self.time = torch.tensor(df.astype({'time': 'int8'})['time'])  # range in [00, 23]

        self.date = torch.zeros([len(df), 6], dtype=torch.int16)
        for _ in range(len(df)):
            self.date[_, 0] = int(df.loc[_, 'time'])  # hour
            date = df.loc[_, 'date']
            self.date[_, 3] = int(date[:4])  # year
            self.date[_, 4] = int(date[4:6])  # month
            self.date[_, 5] = int(date[6:8])  # day

        self.sequence = [Sequence(_) for _ in df['sequence']]
        self.max_sum_duration = max([_.sum_duration for _ in self.sequence])

    def __len__(self):
        return self.length

    def __getitem__(self, idx):
        # udt = torch.tensor([self.userIdx[idx], self.date[idx], self.time[idx]], dtype=torch.int32)
        userIdx = self.userIdx[idx]
        date = self.date[idx]
        sequence = self.sequence[idx]
        itemID = torch.tensor([self.itemID2idx[_['itemID']] for _ in self.sequence[idx].sequence], dtype=torch.int32)
        duration = torch.tensor([_['duration'] for _ in self.sequence[idx].sequence], dtype=torch.int32)
        return userIdx, date, itemID, duration, torch.tensor(len(sequence))


# [How to use 'collate_fn' with dataloaders?]
# (https://stackoverflow.com/a/65875359/12224183)
def collate_fn(data):
    """
    :param data: list of tuples with (utd, sequence idx, labels, len(labels))
    :return:
    """
    userIdxes, dates, itemIdxes, durations, lengths = list(zip(*data))
    return (
        torch.stack(userIdxes),
        torch.stack(dates),
        pad_sequence(itemIdxes, batch_first=True, padding_value=1485),  # if -1, index out of range in Embedding()!!
        pad_sequence(durations, batch_first=True, padding_value=-1),
        torch.stack(lengths)
    )


def my_loss(preds, durations, total_energy):
    """
    :param output: (N, T)
    :param target: (N, T)
    :param target: (N)
    """
    ge0_loss = torch.sum(durations.gt(0) * (durations - preds * total_energy) ** 2)  # [0, 4*te^2)
    # eq0_loss = torch.sum(durations.eq(0) * (torch.tanh(preds) + 1))  # range in [0, 2)
    eq0_loss = torch.sum(durations.eq(0) * preds)
    term_loss = (1 - torch.sum(torch.abs(durations.gt(-1) * preds))) ** 2  # range in [0, (T-1)^2)
    # print('ge0_loss, eq0_loss, term_loss:', ge0_loss, eq0_loss, term_loss)
    return ge0_loss / total_energy + eq0_loss + term_loss * total_energy


def train_loop(model, opt, loss_fn, dataloader, item_len, total_energy, device):
    model.to(device)
    model.train()
    total_loss = 0
    for i, batch in enumerate(dataloader):
        userIdxes, dates, itemIdxes, durations, lengths = batch
        userIdxes = userIdxes.to(device)
        dates = dates.to(device)
        itemIdxes = itemIdxes.to(device)
        durations = durations.to(device)
        # lengths = lengths.to(device)

        tgt_mask = model.get_tgt_mask(size=itemIdxes.size(1)).to(device)
        tgt_key_padding_mask = model.create_pad_mask(matrix=itemIdxes, pad_token=item_len).to(device)

        preds = model(
            userIdxes,
            dates,
            itemIdxes,
            tgt_mask=tgt_mask,
            tgt_key_padding_mask=tgt_key_padding_mask
        ).squeeze()  # (N, T)

        loss = loss_fn(preds, durations, total_energy)

        opt.zero_grad()
        loss.backward()
        opt.step()

        total_loss += loss.detach().item()

    return total_loss / len(dataloader)

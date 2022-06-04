import pandas as pd
import pickle
import time
import tqdm
import numpy as np
import pprint

import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.utils.data import DataLoader


from models.transformer import Model
from utils import TrainDataset, collate_fn, my_loss, train_loop
from torch.utils.tensorboard import SummaryWriter

# load data
load_time = time.time()
data_path = 'mathorcup_recom_listwise/data/'
train_df = pd.read_csv(data_path + 'train_data.csv', dtype=str, nrows=10000)
train_userID = set(train_df['userID'])
userID2idx = {_: i for i, _ in enumerate(train_userID)}
with open(data_path + 'contentID2idx.pickle', 'rb') as handle:
    contentID2idx = pickle.load(handle)
with open(data_path + 'contentTC2ID.pickle', 'rb') as handle:
    contentTC2ID = pickle.load(handle)
item_len = len(contentTC2ID)
assert item_len == 1485
print('load time:', time.time() - load_time)

# create dataset
dataset_time = time.time()
print('start to create train_dataset')
train_dataset = TrainDataset(train_df, userID2idx, contentID2idx)
print('dataset time:', time.time() - dataset_time)

# create dataloader
dataloader_time = time.time()
print('start to create train_dataloader')
train_dataloader = DataLoader(train_dataset, collate_fn=collate_fn, batch_size=512, shuffle=True)
print('dataloader time:', time.time() - dataloader_time)

# train setting
device = "cuda" if torch.cuda.is_available() else "cpu"
model = Model(user_len=len(train_userID), item_len=item_len)
opt = torch.optim.Adam(model.parameters())
loss_fn = my_loss

# train
writer = SummaryWriter('runs/test')
epochs = 100000

for epoch in tqdm.tqdm(range(1, epochs + 1)):
    train_loss = train_loop(
        model=model,
        opt=opt,
        loss_fn=loss_fn,
        dataloader=train_dataloader,
        item_len=item_len,
        total_energy=train_dataset.max_sum_duration,
        device=device
    )
    writer.add_scalar('train_loss', train_loss, epoch)

    if epoch % 1000 == 0:
        print('epoch: {}, train_loss: {}'.format(epoch, train_loss))
        save_path = 'saves/epoch{}-'.format(epoch) + time.strftime("%Y%m%d-%H%M%S")
        torch.save(model.state_dict(), save_path)

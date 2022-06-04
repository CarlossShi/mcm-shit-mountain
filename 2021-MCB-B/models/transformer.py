import torch
import torch.nn as nn
from .date2vec import Date2Vec


class Model(nn.Module):
    def __init__(self, user_len, item_len, d_model=6):
        super(Model, self).__init__()
        self.userID_embeddings = nn.Embedding(user_len, d_model)
        self.itemID_embeddings = nn.Embedding(item_len + 1, d_model)  # if not +1, index out of range in Embedding()!!
        self.date2vec = Date2Vec(k=32, act='sin')  # (N, 6) -> (N, dim_date)
        self.transformer = nn.Transformer(
            d_model=d_model,  # default is 512
            nhead=3,  # default is 4
            num_encoder_layers=6,
            num_decoder_layers=6,
            dim_feedforward=2048,
            dropout=0.1,
            activation='relu',
            custom_encoder=None,
            custom_decoder=None,
            layer_norm_eps=1e-05,
            batch_first=True,
            device=None,
            dtype=None
        )  # (N, T, E) -> (N, T, E)
        self.linear = nn.Linear(d_model, 1)  # (N, T, E) -> (N, T, 1)

    def forward(self, u, d, i, tgt_mask, tgt_key_padding_mask):
        """
        :param u: {Tensor: (N,)}, user indexes
        :param d: {Tensor: (N, 6)}, date
        :param i: {Tensor: (N, T)}, item indexes (target sentence)
        """
        # prepare src
        u = self.userID_embeddings(u)  # (N, dim_user)
        d = self.date2vec(d.float())  # (N, dim_date)
        ud = torch.transpose(torch.stack([u, d]), 1, 0)  # (N, S, E)
        # prepare tgt
        i = self.itemID_embeddings(i)  # (N, T, E)
        # calculate out
        out = self.transformer(src=ud, tgt=i, tgt_mask=tgt_mask, tgt_key_padding_mask=tgt_key_padding_mask)  # (N, T, E)
        out = self.linear(out)  # (N, T, 1)
        return out

    def get_tgt_mask(self, size) -> torch.tensor:
        # Generates a squeare matrix where the each row allows one word more to be seen
        mask = torch.tril(torch.ones(size, size) == 1)  # Lower triangular matrix
        mask = mask.float()
        mask = mask.masked_fill(mask == 0, float('-inf'))  # Convert zeros to -inf
        mask = mask.masked_fill(mask == 1, float(0.0))  # Convert ones to 0

        # EX for size=5:
        # [[0., -inf, -inf, -inf, -inf],
        #  [0.,   0., -inf, -inf, -inf],
        #  [0.,   0.,   0., -inf, -inf],
        #  [0.,   0.,   0.,   0., -inf],
        #  [0.,   0.,   0.,   0.,   0.]]

        return mask

    def create_pad_mask(self, matrix: torch.tensor, pad_token: int) -> torch.tensor:
        # If matrix = [1,2,3,0,0,0] where pad_token=0, the result mask is
        # [False, False, False, True, True, True]
        return (matrix == pad_token)

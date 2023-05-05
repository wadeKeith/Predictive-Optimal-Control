import torch
import torch.nn as nn

from torch.nn import functional as F
from torch.distributions.normal import Normal

class SelectItem(nn.Module):
    def __init__(self, item_index):
        super(SelectItem, self).__init__()
        self._name = 'selectitem'
        self.item_index = item_index

    def forward(self, inputs):
        return inputs[self.item_index]


class MLP(nn.Module):
    def __init__(self):
        super().__init__()
        self.mlp = nn.Sequential(nn.Linear(2, 32),nn.LSTM(32,32,3),SelectItem(item_index=0),nn.Linear(32, 2))

    def forward(self, x):
        out = self.mlp(x)
        pre_mean, pre_std = torch.chunk(out, 2, dim=1)

        pre_std = F.softplus(torch.tensor(pre_std)) + 1e-6

        return pre_mean, pre_std


def log_likelihood(mean, var, y):
    """Calculate log-likelihood for normal distribution"""
    dist = torch.distributions.normal.Normal(mean, var)
    return torch.sum(dist.log_prob(y))


if __name__ == "__main__":
    from data_utils import get_data, add_noise

    x, y = get_data("data/data_ls_2/1 (1).csv")

    noise_y = add_noise(y)

    x_tensor, y_tensor = torch.tensor(x, dtype=torch.float32), torch.tensor(noise_y, dtype=torch.float32)

    model = MLP()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.01)

    for i in range(1000):
        y_pred_mean, y_pre_std = model(x_tensor)

        loss = -log_likelihood(y_pred_mean, y_pre_std, y_tensor)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        # print(i)
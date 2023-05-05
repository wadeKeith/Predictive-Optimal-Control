import torch
import torch.nn as nn

from torch.nn import functional as F

from model_utils import log_likelihood, mse_loss


class MLP(nn.Module):
    def __init__(self):
        super().__init__()
        self.mlp = nn.Sequential(nn.Linear(2, 32), nn.Linear(32, 2))

    def forward(self, x):
        out = self.mlp(x)
        pre_mean, pre_std = torch.chunk(out, 2, dim=1)

        pre_std = F.softplus(pre_std) + 1e-6

        return pre_mean, pre_std


if __name__ == "__main__":
    from data_utils import get_data, add_noise

    x, y = get_data("data/data_ls_2/1 (1).csv")

    noise_y = add_noise(y)

    x_tensor, y_tensor = torch.tensor(x, dtype=torch.float32), torch.tensor(noise_y, dtype=torch.float32)

    model = MLP()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.01)

    for i in range(1000):
        y_pred_mean, y_pre_std = model(x_tensor)
        loss = mse_loss(y_pred_mean, y_pre_std, y_tensor)
        # loss = -log_likelihood(y_pred_mean, y_pre_std, y_tensor)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        if i % 100 == 0:
            print(abs(y_pred_mean - y_tensor).mean().item())
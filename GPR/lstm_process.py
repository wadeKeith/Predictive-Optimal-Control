import torch
import torch.nn as nn
from torch.nn import functional as F
from torch.utils.data import DataLoader


from data_utils import LstmTrainData
from model_utils import log_likelihood, mse_loss

device = torch.device("cuda:1" if torch.has_cuda else "cpu")
class LSTM(nn.Module):
    def __init__(self, input_size, hidden_size, output_size, num_layers, lstm_seq_len):
        super().__init__()
        self.input_size = input_size
        self.hidden_size = hidden_size
        self.output_size = output_size
        self.num_layers = num_layers
        self.lstm_seq_len = lstm_seq_len
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers, batch_first=True)
        self.linear = nn.Linear(hidden_size, output_size)

    def forward(self, x):
        h0 = torch.zeros(self.num_layers, x.size(0), self.hidden_size)
        c0 = torch.zeros(self.num_layers, x.size(0), self.hidden_size)
        batch_size = x.size(0)
        x = x.view(batch_size, self.lstm_seq_len, 2)
        out, _ = self.lstm(x, (h0, c0))
        out = self.linear(out[:, -1, :])
        pre_mean, pre_std = torch.chunk(out, 2, dim=1)
        pre_std = F.softplus(pre_std) + 1e-6
        return pre_mean, pre_std


if __name__ == "__main__":
    train_dataset = LstmTrainData()
    train_dataloader = DataLoader(train_dataset, batch_size=32, shuffle=True)

    model = LSTM(input_size=2, hidden_size=12, output_size=2, num_layers=1, lstm_seq_len=train_dataset.x_len).to(device)

    optimizer = torch.optim.Adam(model.parameters(), lr=0.1)

    for i in range(10000):
        mse_losses = []
        log_losses = []
        for batch_x, batch_y in train_dataloader:
            y_pred_mean, y_pre_std = model(batch_x)

            loss = -log_likelihood(y_pred_mean, y_pre_std, batch_y)
            # loss = mse_loss(y_pred_mean, y_pre_std, batch_y)

            mse_losses.append(abs(y_pred_mean - batch_y).mean().item())

            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
        if i % 100 == 0:
            print("loss: ", sum(mse_losses) / len(mse_losses))
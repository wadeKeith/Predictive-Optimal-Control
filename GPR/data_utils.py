import os
import numpy as np
import pandas as pd
from torch.utils.data import Dataset


def add_noise(x, noise_sigma=0.0):
    y = x + np.random.normal(0, noise_sigma, size=x.shape)
    return y


def get_data(file_path: str):
    df = pd.read_csv(file_path, encoding="gbk", low_memory=False)
    x = df[["v_Vel", "v_Acc"]].values[:-1]
    y = df["v_Acc"].values[1:]
    return x, y


class LstmTrainData(Dataset):
    def __init__(self) -> None:
        super().__init__()
        file_dir = "data/data_ls_2"  # file dir path
        self.x_len = 1
        assert self.x_len > 0, "x_len must be greater than 0"
        np.random.seed(1)
        data_file = os.listdir(file_dir)
        train_data_files = [file_dir + f"/{file}" for file in data_file if file != "1 (1209).csv"]
        test_data_files = [file_dir + f"/{file}" for file in data_file if file == "1 (1209).csv"]

        self.x_train, self.y_train = [], []
        for train_data_file in train_data_files:
            x, y = get_data(train_data_file)
            for i in range(len(x) - self.x_len):
                self.x_train.extend([np.hstack(x[i : i + self.x_len], dtype=np.float32)])
                self.y_train.extend(np.array([y[i + self.x_len - 1]], dtype=np.float32))
        print("data_set init success!")

    def __len__(self):
        """
        # this function is called when you do len(instance)
        """
        return len(self.x_train)

    def __getitem__(self, index):
        """
        This function is called when you do instance[index]

        Args:
            index (int): index of the instance you want to get

        Returns:
            tuple: (x, y) where x is input and y is label
        """
        return self.x_train[index], self.y_train[index]


if __name__ == "__main__":
    # x, y = get_data("data/data_ls_2/1 (1).csv")
    lstm_data_train_set = LstmTrainData()
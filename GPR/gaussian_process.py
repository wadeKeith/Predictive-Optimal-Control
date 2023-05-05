from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import ConstantKernel, RBF
from matplotlib import pyplot as plt
import numpy as np
import pandas as pd
from sklearn.gaussian_process.kernels import DotProduct, WhiteKernel

from data_utils import get_data, add_noise

x, y = get_data("data/data_ls_2/1 (1).csv")

noise_y = add_noise(y)

kernel = DotProduct() + WhiteKernel()
# kernel = ConstantKernel(constant_value=0.2, constant_value_bounds=(1e-4, 1e4)) * RBF(length_scale=1, length_scale_bounds=(1e-4, 1e4))
gpr = GaussianProcessRegressor(kernel=kernel, n_restarts_optimizer=3, normalize_y=True)
gpr.fit(x, noise_y)

test_x, test_y = get_data("data/data_ls_2/1 (2).csv")


Mu = np.zeros([len(test_x), 5])
Cov = np.zeros([len(test_x), 5])

for i in range(0, len(test_x)):
    test_f = test_x[i, :]
    for j in range(0, 5):  # 这个地方可以在求解最优控制中再选择下一步的加速度具体值，这里取期望只是验证代码可行性
        mu, cov = gpr.predict(test_f.reshape(1, -1), return_cov=True)
        Mu[i, j] = mu
        Cov[i, j] = cov
        v_loop = np.array(test_f[0] + test_f[1] * 0.1)
        test_f = np.hstack((v_loop, mu))
Mu_plot = Mu[:,0]
Cov_plot = Cov[:,0]
uncertainty1 = 3* np.square(Cov_plot)
uncertainty2 = 6* np.square(Cov_plot)
uncertainty3 = 9* np.square(Cov_plot)
t = np.arange(0,len(test_y),1)
pred=Mu_plot.ravel()

plt.figure()
plt.fill_between(t.ravel(), pred + uncertainty1, pred - uncertainty1, color="g",alpha=0.1)
plt.fill_between(t.ravel(), pred +uncertainty2, pred + uncertainty1,color="b", alpha=0.2)
plt.fill_between(t.ravel(), pred -uncertainty1, pred - uncertainty2,color="b", alpha=0.2)
plt.fill_between(t.ravel(), pred + uncertainty3, pred  + uncertainty2, color="r",alpha=0.3)
plt.fill_between(t.ravel(), pred -uncertainty2, pred - uncertainty3, color="r",alpha=0.3)
plt.plot(t, pred, label="predict")
plt.scatter(t, test_y, label="real", c="red", marker="x")
plt.legend()
plt.show()

Mu_op = pd.DataFrame(Mu)
Cov_op = pd.DataFrame(Cov)
Mu_op.to_csv("Mu_3.csv", index=False, header=False)
Cov_op.to_csv("Cov_3.csv", index=False, header=False)

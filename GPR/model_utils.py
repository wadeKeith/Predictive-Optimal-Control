
import torch
from torch.distributions.normal import Normal


def log_likelihood(mean, var, y):
    """Calculate log-likelihood for normal distribution"""
    dist = Normal(mean, var)
    return torch.sum(dist.log_prob(y))

def mse_loss(mean, var, y):
    """Calculate MSE loss"""
    return torch.mean((mean - y) ** 2)
# Summary

The DEX contract relies on a centralized price oracle based on its own reserves. 

> This is both one of the most common methods used to attack protocols and one of the easiest DeFi security attack vectors to prevent. If you’re using `getReserves()` as a way to quantify price, this should be a red flag. This centralized price oracle exploit occurs when a user manipulates the spot price of an order book or automated market maker-based decentralized exchange (DEX), often through the use of a flash loan. The protocol then uses the price reported by the DEX as their price oracle, causing distortions in the smart contract’s execution in the form of triggering false liquidations, issuing excessively large loans, or triggering unfair trades. Due to this vulnerability, even popular DEXs such as Uniswap don’t recommend using their reserves alone as a pricing oracle.  

*Ref: https://blog.chain.link/defi-security-best-practices/*

![](https://user-images.githubusercontent.com/19994887/161902944-7f06e721-08fe-4e55-a005-620a3e31be0f.png)

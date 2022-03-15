## OpenZeppelin Ethernaut CTF solved & tested with Foundry

Writeups available at: https://eval.hashnode.dev/series/ethernaut-ctf

## Info

This repo is setup to enable you to run the Ethernaut levels locally rather than on Rinkeby.

As a result you will see some contracts that are not related to individual level but instead to Ethernaut's core contracts which determine if you have passed the level. 

These are the `Ethernaut.sol` & `BaseLevel.sol` contracts in the `/core` directory, each challenge contract in the `/levels` directory and their corresponding solutions in the `/test` directory. 

**File Locations**

Individual Levels can be found in their respective folders in the ./src folder.  

Eg [Fallback is located in ./src/levels/01-Fallback/Fallback.sol](src/levels/01-Fallback/Fallback.sol)


Tests for each level can be found in the ./src/test folder and have the naming convention [LEVEL_NAME].t.sol 

Eg [Fallback test are located in ./src/test/01-Fallback.t.sol](src/test/01-Fallback.t.sol)

*NB: Solc compiler is updated to ^v0.8.10 for all contracts, certain code changes were required for compatibility issues. They will be highlighted in comments if need be* 


## References

**Ethernaut**

https://ethernaut.openzeppelin.com/

**Foundry**

https://github.com/gakonst/foundry

**Credits to original repository idea**

https://github.com/ciaranmcveigh5/ethernaut-x-foundry


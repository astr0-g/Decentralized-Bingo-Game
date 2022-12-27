<a name="readme-top"></a>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

<!-- [![LinkedIn][linkedin-shield]][linkedin-url] -->

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/Astr0-G/Decentralized-Bingo-Game">
    <img src="https://cdn.discordapp.com/attachments/960590776570626098/1057037803889885274/Bingologo.png" alt="Logo" height="80">
  </a>

  <h3 align="center">Dencentralized Bingo Game</h3>

  <p align="center">
    Dencentralized Bingo Game basis for EVM chain
    <br />
    <a href="https://github.com/Astr0-G/Decentralized-Bingo-Game"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/Astr0-G/Decentralized-Bingo-Game/issues">Report Bug</a>
    <br/><br />
    <br />
    dencentralized bingo game on Goerli Testnet Network <br/>
    <a href="https://goerli.etherscan.io/address/0xF7756666306c26c82DA2650DFeD9636Bc6676B61#code">Bingo game smart contract</a><br/>
    <a href="https://goerli.etherscan.io/address/0x711601a3dc57377e6567c89dcd55ca05baca126b#code">Bingo Token smart contract</a><br/>
    <a href="https://github.com/Astr0-G/Decentralized-Bingo-Game/tree/main/deployments/goerli"><strong>Explore the deployment data »</strong></a>
    <br />
    
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li>
      <a href="#Test-Summary-and-Gas-Report">Test Summary and Gas Report</a>
      <ul>
        <li><a href="#Test-Summary">Test Summary</a></li>
        <li><a href="#Gas-Report">Gas Report</a></li>
      </ul>
    </li>
    <li><a href="#Interface-abi">Interface-abi</a></li>
    <li><a href="#Public-API">Public-API</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>

  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About The Project

Dencentralized Bingo Game

Bingo is a luck-based game in which players match a randomized board of numbers with random numbers drawn by a host. The first player to achieve a line of numbers on their board and claim Bingo wins.

[BasicBingoGame.sol](https://github.com/Astr0-G/Decentralized-Bingo-Game/blob/main/contracts/BasicBingoGame.sol): this is the game version for test cases, test for optimize gas and logic.

- Draw winners function and claim prize function are sticked together as "drawWinnerOrClaimPrize"(there is no need for automation keepers to involve for this contract)

- Support 4 players in a game as default(could change on game needs)

- Support unlimited multiple concurrent games

- Each player pays an ERC20 entry fee: Bingo Token, transferred on join

- Winner wins the pot of entry fees(player needs to claim their prize or bet by calling "drawWinnerOrClaimPrize" function)

- Games have a minimum join duration before start

- Games have a minimum turn duration between draws

- Admin can update the entry fee: Bingo Token, join duration, turn duration, whether return bet and max plyer in one game

[BingoGame.sol](https://github.com/Astr0-G/Decentralized-Bingo-Game/blob/main/contracts/BingoGame.sol): this is the game version for real world cases, which is the one deployed on Goerli testnet.

- Draw winners function "drawWinner" will be called by automation keeper

- Support 4 players in a game as default(could change on game needs)

- Support unlimited multiple concurrent games

- Each player pays an ERC20 entry fee: Bingo Token, transferred on join

- Winner wins the pot of entry fees, transferred on win(player needs to claim their bet back by calling "claimPrize" function)

- Games have a minimum join duration before start

- Games have a minimum turn duration between draws

- Admin can update the entry fee: Bingo Token, join duration, turn duration, whether return bet and max plyer in one game

[BingoToken.sol](https://github.com/Astr0-G/Decentralized-Bingo-Game/blob/main/contracts/BingoToken.sol):
Normal ERC20 standard token

more infos:

- ReturnBet sets to true as default means returns bet token amount when there is no winner for a game
- Random numbers is generated with blockhash(block.number - 1)
- Duplicate numbers may be drawn, but have no effect on the game
- Boards may have duplicate numbers that can be marked by one drawn number
- Each game number is between 0 and 64
- Players are online to claim a game board and prize with transaction

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

This section contains frameworks/libraries used to bootstrap Bingo Game, it includes the smart contract and api.

[![hardhat][hardhat]][hardhat-url]  
 [![node.js][node.js]][node-url]  
 [![django][django]][django-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->

## Getting Started

There are four parts of the files: [smart contract files](https://github.com/Astr0-G/Decentralized-Bingo-Game/tree/main/contracts),[nodeJs Interface files](https://github.com/Astr0-G/Decentralized-Bingo-Game/tree/main/scripts/interface),[Nodejs monitor files](https://github.com/Astr0-G/Decentralized-Bingo-Game/tree/main/scripts/monitor),[Django REST API files](https://github.com/Astr0-G/Decentralized-Bingo-Game/tree/main/public-api).

### Prerequisites

- npm

  ```sh
  npm install npm@latest -g
  ```

- python  
  python version >= 3.7.9  
  Download from [here](https://www.python.org/downloads/)

### Installation

###### you can skip 6-8 if you are only testing smart contracts

1.  Clone the repo
    ```sh
    git clone https://github.com/Astr0-G/Decentralized-Bingo-Game.git
    ```
2.  Install node_modules

    ```sh
    npm install
    ```

    or

    ```sh
    yarn
    ```

3.  create a .env file

    create a .env file and put

        ```
        RINKEBY_PRIVATE_KEY=0xdf57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e
        MUMBAI_PRIVATE_KEY=0xdf57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e
        RINKEBY_RPC_URL=https://eth-rinkeby.alchemyapi.io/v2/12345
        PASSWORD=
        GOERLI_RPC_URL=https://goerli.infura.io/v3/12345
        ETHERSCAN_API_KEY=
        COINMARKET_KEY=
        MUMBAI_RPC_URL=https://polygon-mumbai.infura.io/v3/12345
        ARB_RPC_URL=https://arbitrum-mainnet.infura.io/v3/12345
        rpc=''
        ```

4.  smart contract test

    ```
    yarn hardhat test

    ```

5.  smart contract deploy

    hardhat local network deploy

    ```
    yarn hardhat deploy
    ```

    deploy BingoToken.sol and Bingo.sol to goerli

    ```
    yarn hardhat deploy --network goerli --tags bingo
    ```

6.  run interface scripts

    ```
    yarn hardhat getplayers
    yarn hardhat getplayergameboard
    yarn hardhat getroundbingoresult
    yarn hardhat getbingobasicdetails
    yarn hardhat checkwinner

    ```

7.  run monitor scripts(monitor sctips is running, feel free to test on goerli testnet)

    ```
    yarn hardhat monitor

    ```

8.  Django rest api

    ```
    cd public-api

    ```

    create a .env file and put

    ```
    providerurl=https://eth-goerli........
    ```

    install requirements.txt

    ```
    python manage.py migrate

    ```

    ```
    python manage.py runserver

    ```

    you may choose [Postman](https://www.postman.com/) to test REST api

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Test-Summary-and-Gas-Report

### Test-Summary

<p align="center" text="sm">test case 1</p>
<p align="center" text="sm">one player achieved the bingo in the earliest round and got their the pot of entry fee: Bingo Token</p>
<p align="center"><img alt="bingo" src="https://cdn.discordapp.com/attachments/960590776570626098/1057061355330478131/case1.png"></p><br/>

<p align="center" text="sm">test case 2</p>
<p align="center" text="sm">two or more players achieved the bingo in the same earliest round and split the pot of entry fee: Bingo Token</p>
<p align="center" text="sm">changed generated number range from 64 to 10 just for this test</p>
<p align="center"><img alt="bingo" src="https://cdn.discordapp.com/attachments/960590776570626098/1057129480436588554/case2.png"></p><br/>

<p align="center" text="sm">test case 3</p>
<p align="center" text="sm">no players achieved the bingo</p>
<p align="center" text="sm">return bet is setting to false on this case</p>
<p align="center"><img alt="bingo" src="https://cdn.discordapp.com/attachments/960590776570626098/1057135512911085638/testcase3.png"></p><br/>

<p align="center" text="sm">test summary</p>
<p align="center"><img alt="bingo" src="https://cdn.discordapp.com/attachments/960590776570626098/1057132420312350740/testsummary.png"></p><br/>

<p align="center" text="sm">nodejs monitor with keeper log</p>

<p align="center"><img alt="bingo" src="https://cdn.discordapp.com/attachments/960590776570626098/1057133317176172574/monitorwithkeepr.png"></p><br/>
<p align="center" text="sm">keeper call drawWinner function 6 mins after the game round created</p>
<p align="center"><img alt="bingo" src="https://cdn.discordapp.com/attachments/960590776570626098/1057388369941897297/WX20221227-1201472x.png"></p><br/>

<p align="center" text="sm">Call interface test</p>
<p align="center"><img alt="bingo" src="https://cdn.discordapp.com/attachments/960590776570626098/1057138073458188379/callinterfacetest.png"></p><br/>

### Gas-Report

<p align="center" text="sm">gas report</p>
<p align="center" text="sm">`drawWinner` function max gas used is the worst case that there is no winners drawed</p>
<p align="center"><img alt="bingo" src="https://cdn.discordapp.com/attachments/960590776570626098/1057139285435879444/gas-report.png"></p><br/>

<p align="center" text="sm">slither report</p>
<p align="center" text="sm">you can use yarn slither to do the test, make sure you have slither installed</p>
<p align="center"><img alt="bingo" src="https://cdn.discordapp.com/attachments/960590776570626098/1057184342591406152/1672122782409.jpg"></p><br/>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- Interface -->

## Interface-abi

interface file of [BingoGame.sol](https://github.com/Astr0-G/Decentralized-Bingo-Game/blob/main/contracts/BingoGame.sol) is [abi.json](https://github.com/Astr0-G/Decentralized-Bingo-Game/blob/main/abi.json)

NodeJs scripts:

[checkWinner](https://github.com/Astr0-G/Decentralized-Bingo-Game/blob/main/scripts/interface/checkWinner.js) : for frontend to check if the player is winner

[getBingoBasicDetails](https://github.com/Astr0-G/Decentralized-Bingo-Game/blob/main/scripts/interface/getBingoBasicDetails.js) : for frontend to get bingo basic details

[getPlayerGameBoard](https://github.com/Astr0-G/Decentralized-Bingo-Game/blob/main/scripts/interface/getPlayerGameBoard.js) : for frontend to render player game number board

[getPlayers](https://github.com/Astr0-G/Decentralized-Bingo-Game/blob/main/scripts/interface/getPlayers.js) : for frontend to get players address in a round of game

[getRoundBingoResult](https://github.com/Astr0-G/Decentralized-Bingo-Game/blob/main/scripts/interface/getRoundBingoResult.js) : for frontend to get specific round of Bingo result

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- Interface -->

## Public-API

API are constructed based on Django, [check the files here](https://github.com/Astr0-G/Decentralized-Bingo-Game/tree/main/public-api).

API endpoints:

[get bingo game details](https://www.decentralizedbingogame.live/api/getbingobasicdetails/)
`https://www.decentralizedbingogame.live/api/getbingobasicdetails/`

[get player game board](https://www.decentralizedbingogame.live/api/getplayergameboard/0x51580828DF98f7d9Bb09a0410795183fe6183E14/1/)
`https://www.decentralizedbingogame.live/api/getplayergameboard/<playeraddress>/<gameround>/`

[get player from gameround](https://www.decentralizedbingogame.live/api/getplayer/2/)
`https://www.decentralizedbingogame.live/api/getplayer/<gameround>/`

[get round bingo result and winning numbers from game round](https://www.decentralizedbingogame.live/api/getroundbingoresult/2/)
`https://www.decentralizedbingogame.live/api/getroundbingoresult/<gameround>/`

[check if player is winner in the game round](https://www.decentralizedbingogame.live/api/checkwinner/0x51580828DF98f7d9Bb09a0410795183fe6183E14/2/)
`https://www.decentralizedbingogame.live/api/checkwinner/<playeraddress>/<gameround>/`

[get all round detils](https://www.decentralizedbingogame.live/api/get10rounddetils/)  
`https://www.decentralizedbingogame.live/api/get10rounddetils/`
\*For get all round details, will soon make it to 10 rounds of data showing, because there is no database Django using right now, will need to set up database later on to save data into bingo game database everytime when emit an event which is also for best performance for frontend.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Function Branch (`git checkout -b new/Function`)
3. Commit your Changes (`git commit -m 'Add some Function'`)
4. Push to the Branch (`git push origin function/Function`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->

## License

Distributed under the MIT License. See [`LICENSE.txt`](https://github.com/Astr0-G/Decentralized-Bingo-Game/blob/main/LICENSE.txt) for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->

## Contact

astro - [@lil_astr_0](https://twitter.com/lil_astr_0) - wangge326@gmail.com

Project Link: [github](https://github.com/Astr0-G/Decentralized-Bingo-Game)

please dm on [twitter](https://twitter.com/lil_astr_0) if you need Goerli Testnet Native Token to test Bingo Game, I am happy to help!

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/Astr0-G/Decentralized-Bingo-Game.svg?style=for-the-badge
[contributors-url]: https://github.com/Astr0-G/Decentralized-Bingo-Game/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/Astr0-G/Decentralized-Bingo-Game.svg?style=for-the-badge
[forks-url]: https://github.com/Astr0-G/Decentralized-Bingo-Game/network/members
[stars-shield]: https://img.shields.io/github/stars/Astr0-G/Decentralized-Bingo-Game.svg?style=for-the-badge
[stars-url]: https://github.com/Astr0-G/Decentralized-Bingo-Game/stargazers
[issues-shield]: https://img.shields.io/github/issues/Astr0-G/Decentralized-Bingo-Game.svg?style=for-the-badge
[issues-url]: https://github.com/Astr0-G/Decentralized-Bingo-Game/issues
[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=for-the-badge
[license-url]: https://github.com/Astr0-G/Decentralized-Bingo-Game/blob/main/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/othneildrew
[product-screenshot]: https://cdn.discordapp.com/attachments/960590776570626098/1042591497813504040/logo2.png
[next.js]: https://img.shields.io/badge/next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[next-url]: https://nextjs.org/
[react.js]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[react-url]: https://reactjs.org/
[vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[vue-url]: https://vuejs.org/
[angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[angular-url]: https://angular.io/
[svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[svelte-url]: https://svelte.dev/
[laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[laravel-url]: https://laravel.com
[bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[bootstrap-url]: https://getbootstrap.com
[jquery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[jquery-url]: https://jquery.com
[wagmi]: https://img.shields.io/badge/wagmi.sh-20232A?style=for-the-badge&logo=&logoColor=61DAFB
[wagmi-url]: https://wagmi.sh/
[django]: https://img.shields.io/badge/Django-35495E?style=for-the-badge&logo=django&logoColor=yellowgreen
[django-url]: https://www.djangoproject.com/
[node.js]: https://img.shields.io/badge/Node.js-563D7C?style=for-the-badge&logo=nodedotjs&logoColor=white
[node-url]: https://nodejs.org/en/
[hardhat]: https://img.shields.io/badge/Hardhat-ffff00?style=for-the-badge&logo=&logoColor=white
[hardhat-url]: https://hardhat.org/
[vercel]: https://img.shields.io/badge/Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white
[vercel-url]: https://vercel.com/docs
[python]: https://img.shields.io/badge/Python-20232A?style=for-the-badge&logo=python&logoColor=white
[python-url]: https://www.python.org/
[filecoin]: https://img.shields.io/badge/Filecoin-55AAFF?style=for-the-badge&logo=&logoColor=61DAFB
[filecoin-url]: https://filecoin.io/
[nftsotrage]: https://img.shields.io/badge/nft.sotrage-55AAFF?style=for-the-badge&logo=&logoColor=61DAFB
[nftsotrage-url]: https://nft.storage/
[estuary]: https://img.shields.io/badge/Estuary-55AAFF?style=for-the-badge&logo=&logoColor=61DAFB
[estuary-url]: https://estuary.tech/

[left]: https://img.shields.io/badge/[-55AAFF?style=for-the-badge&logo=&logoColor=61DAFB
[right]: https://img.shields.io/badge/]-55AAFF?style=for-the-badge&logo=&logoColor=61DAFB
[chainlink]:https://img.shields.io/badge/chainlink-949494?style=for-the-badge&logo=chainlink&logoColor=1663be
[chainlink-url]:https://chain.link/

```

```

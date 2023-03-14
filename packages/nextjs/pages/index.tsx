import type { NextPage } from "next";
import Head from "next/head";
import { BugAntIcon, SparklesIcon } from "@heroicons/react/24/outline";
import Link from "next/link";
import React from "react";

import { ContractUI } from "~~/components/scaffold-eth";

const Home: NextPage = () => {
  return (
    <>
      <Head>
        <title>Gas Lovers NFT</title>
        <meta name="description" content="Created with 🏗 scaffold-eth" />
      </Head>
      <div className="flex items-center flex-col flex-grow pt-10">
        {/* <div className="aspect-square w-[500px] bg-[#eab308] grid place-items-center font-[helvetica_neue]">
          <div className="w-[100%] p-[3%] aspect-square bg-[#0c4a6e] grid grid-rows-3 place-items-center overflow-hidden">
            <div className="flex flex-col justify-center items-center place-self-start w-full">
              <div className="text-3xl">33.45 gwei</div>
              <div className="text-sm">Mint Gas Price</div>
            </div>
            <div className="flex flex-col justify-center items-center">
                <div className="text-[rgba(255,255,255,0)] text-9xl font-bold bg-gradient-to-r from-pink-500 via-red-500 to-yellow-500 bg-clip-text">#12</div>
                <div className="text-sm">Gas Price Ranking</div>
            </div>
            <div className="flex flex-col justify-between place-self-end w-full">
              <div className="flex flex-col justify-center items-center">
                <div className="text-sm">Minter</div>
                <div className="text-lg">0xC2172a6315c1D7f6855768F843c420EbB36eDa97</div>
              </div>
            </div>

          </div>
          
        </div> */}
        
        
        <div className="px-5">
          <h1 className="text-center mb-8">
            <span className="block text-2xl mb-2">Welcome Gas Lovers!</span>
          </h1>
          <ContractUI contractName="GasLover" />
          <p className="text-center text-lg">
            Get started by editing{" "}
            <code className="italic bg-base-300 text-base font-bold">packages/nextjs/pages/index.tsx</code>
          </p>
          <p className="text-center text-lg">
            Edit your smart contract <code className="italic bg-base-300 text-base font-bold">YourContract.sol</code> in{" "}
            <code className="italic bg-base-300 text-base font-bold">packages/hardhat/contracts</code>
          </p>
        </div>

        <div className="flex-grow bg-base-300 w-full mt-16 px-8 py-12">
          <div className="flex justify-center items-center gap-12 flex-col sm:flex-row">
            <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center max-w-xs rounded-3xl">
              <BugAntIcon className="h-8 w-8 fill-secondary" />
              <p>
                Tinker with your smart contract using the{" "}
                <Link href="/debug" passHref className="link">
                  Debug Contract
                </Link>{" "}
                tab.
              </p>
            </div>
            <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center max-w-xs rounded-3xl">
              <SparklesIcon className="h-8 w-8 fill-secondary" />
              <p>
                Experiment with{" "}
                <Link href="/example-ui" passHref className="link">
                  Example UI
                </Link>{" "}
                to build your own UI.
              </p>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Home;

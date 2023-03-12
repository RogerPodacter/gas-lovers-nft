import { FunctionFragment } from "ethers/lib/utils";
import { Dispatch, SetStateAction, useState } from "react";
import { useContractWrite, useNetwork, useWaitForTransaction } from "wagmi";
import InputUI from "./InputUI";
import TxReceipt from "./TxReceipt";
import { getFunctionInputKey, getParsedContractFunctionArgs, getParsedEthersError } from "./utilsContract";
import { TxValueInput } from "./utilsComponents";
import { useTransactor } from "~~/hooks/scaffold-eth";
import { notification, parseTxnValue, getTargetNetwork } from "~~/utils/scaffold-eth";
import { ethers } from "ethers";

// TODO set sensible initial state values to avoid error on first render, also put it in utilsContract
const getInitialFormState = (functionFragment: FunctionFragment) => {
  const initialForm: Record<string, any> = {};
  functionFragment.inputs.forEach((input, inputIndex) => {
    const key = getFunctionInputKey(functionFragment, input, inputIndex);
    initialForm[key] = "";
  });
  return initialForm;
};

type TWriteOnlyFunctionFormProps = {
  functionFragment: FunctionFragment;
  contractAddress: string;
  setRefreshDisplayVariables: Dispatch<SetStateAction<boolean>>;
};

export const WriteOnlyFunctionForm = ({
  functionFragment,
  contractAddress,
  setRefreshDisplayVariables,
}: TWriteOnlyFunctionFormProps) => {
  const [form, setForm] = useState<Record<string, any>>(() => getInitialFormState(functionFragment));
  const [txValue, setTxValue] = useState("");
  const { chain } = useNetwork();
  const configuredChain = getTargetNetwork();
  const writeTxn = useTransactor();
  const writeDisabled = !chain || chain?.id !== configuredChain.id;

  // We are omitting usePrepareContractWrite here to avoid unnecessary RPC calls and wrong gas estimations.
  // See:
  //   - https://github.com/scaffold-eth/se-2/issues/59
  //   - https://github.com/scaffold-eth/se-2/pull/86#issuecomment-1374902738
  const {
    data: result,
    isLoading,
    writeAsync,
  } = useContractWrite({
    address: contractAddress,
    functionName: functionFragment.name,
    abi: [functionFragment],
    args: getParsedContractFunctionArgs(form),
    mode: "recklesslyUnprepared",
    overrides: {
      value: txValue ? parseTxnValue(txValue) : undefined,
      gasPrice: ethers.utils.parseUnits("30", 'gwei'),
    },
  });

  const handleWrite = async () => {
    if (writeAsync) {
      try {
        await writeTxn(writeAsync());
        setRefreshDisplayVariables(prevState => !prevState);
      } catch (e: any) {
        const message = getParsedEthersError(e);
        notification.error(message);
      }
    }
  };

  const { data: txResult } = useWaitForTransaction({
    hash: result?.hash,
  });

  // TODO use `useMemo` to optimize also update in ReadOnlyFunctionForm
  const inputs = functionFragment.inputs.map((input, inputIndex) => {
    const key = getFunctionInputKey(functionFragment, input, inputIndex);
    return (
      <InputUI
        key={key}
        setForm={setForm}
        form={form}
        stateObjectKey={key}
        paramType={input}
        functionFragment={functionFragment}
      />
    );
  });
  const zeroInputs = inputs.length === 0 && !functionFragment.payable;

  return (
    <div className="py-5 space-y-3 first:pt-0 last:pb-1">
      <div className={`flex gap-3 ${zeroInputs ? "flex-row justify-between items-center" : "flex-col"}`}>
        <p className="font-medium my-0 break-words">{functionFragment.name}</p>
        {inputs}
        {functionFragment.payable ? <TxValueInput setTxValue={setTxValue} txValue={txValue} /> : null}
        <div className="flex justify-between gap-2">
          {!zeroInputs && (
            <div className="flex-grow basis-0">{txResult ? <TxReceipt txResult={txResult} /> : null}</div>
          )}
          <div
            className={`flex ${
              writeDisabled &&
              "tooltip before:content-[attr(data-tip)] before:right-[-10px] before:left-auto before:transform-none"
            }`}
            data-tip={`${writeDisabled && "Wallet not connected or in the wrong network"}`}
          >
            <button
              className={`btn btn-secondary btn-sm ${isLoading ? "loading" : ""}`}
              disabled={writeDisabled}
              onClick={handleWrite}
            >
              Send 💸
            </button>
          </div>
        </div>
      </div>
      {zeroInputs && txResult ? (
        <div className="flex-grow basis-0">
          <TxReceipt txResult={txResult} />
        </div>
      ) : null}
    </div>
  );
};

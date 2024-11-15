// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.6.2 <0.9.0;
pragma experimental ABIEncoderV2;

import { Sample } from "src/mocks/Sample.sol";
import { Contract } from "../utils/Contract.sol";
import { ISharedArgument, SampleMigration } from "../SampleMigration.s.sol";
import { SampleDeploy } from "./SampleDeploy.s.sol";

contract SampleCloneDeploy is SampleMigration {
  function _injectDependencies() internal virtual override {
    // simple creation for deploy migration
    _setDependencyDeployScript(Contract.Sample.key(), new SampleDeploy());
    // create deploy migration with deterministic address
    _setDependencyDeployScript(
      Contract.Sample.key(), deploySharedMigration(Contract.Sample.key(), type(SampleDeploy).creationCode)
    );
  }

  function _defaultArguments() internal virtual override returns (bytes memory args) {
    ISharedArgument.SharedParameter memory param = config.sharedArguments();
    args = abi.encode(param.message);
  }

  function run() public virtual returns (Sample instance) {
    instance = Sample(_deployImmutable(Contract.SampleClone.key()));
    assertEq(instance.getMessage(), config.sharedArguments().message);
  }
}

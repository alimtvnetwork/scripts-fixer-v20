---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/export-chrome-profile.ps1]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section5"
  canonical_size: "spec/02-coding-guidelines/00-canonical-size-tier.md"
  language_guideline: "spec/02-coding-guidelines/08-file-folder-naming/powershell.md"
  boolean_styling: "spec/02-coding-guidelines/01-cross-language/02-boolean-principles/01-naming-prefixes.md"
  folder_naming: "spec/02-coding-guidelines/08-file-folder-naming/powershell.md"
  error_architecture: "spec/03-error-manage/02-error-architecture/00-overview.md"
  error_codes: "spec/21-app/07-error-and-logging/01-error-code-allocation.md"
  logging_traces: "spec/21-app/07-error-and-logging/02-logging-and-stack-traces.md"
  response_envelope: "spec/21-app/07-error-and-logging/03-response-envelope.md"
  golden_fixture: "spec/21-app/fixtures/chrome-profile-export.example.json"
  strictly_avoid: ".lovable/strictly-avoid.md"
  database: "n/a — no db"
  ui_surface: "n/a — cli"
  tests: "unit test-5"
  ci_cd_guard: "linter-scripts/check-powershell.ps1"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 005 — Extensions Export Parse (PS1)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for ExtensionsExportParse(PS1).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Parse Preferences -> extensions.settings. Skip component extensions. c7c6cf14-075a-46cf-9823-42be42af4653 5d8b59a8-c5ca-4c54-87b6-10123f68c4aa 8ec71fde-608c-4910-9122-d29122fa41f7 4ab780e4-bd12-4c73-b30c-1010353125a5 11f3740c-0146-4f7a-b2d6-cfb35bac6b19 464f1348-7c51-4237-8c34-3e0a4abfb0e9 e3ab30c4-247a-4187-95be-b486b73237c6 71f0038b-0e61-41dd-98fd-56df8f3e82b2 eb57850d-6361-46d3-b02b-3b7ad2532172 2cd5768b-abd3-4e3d-94af-0a75f9c405dc cb90e6d5-fda4-47cd-ae85-c3ecf933214c 251c4bc1-9e4a-4af3-824e-b22a3b4b1311 6381d9fc-7823-49d3-ae9c-a8feb7ce6056 6cf3ef9f-4f45-42f1-b54f-8ecfb08de709 ee9c4cb4-92ea-407d-b7c7-540ee343f2a7 9fb4f1c0-cbf5-4ab3-92f5-6e6c56aea4eb 144a9555-c602-47de-8abf-7e1bfc90a248 39554366-137d-4ef8-91de-777880696102 4ae178dc-586b-49cc-964c-f7580a960975 a764979d-00c0-4274-a88b-538001e5e32a 6ea0e85b-f755-4016-98db-80b2a1f45b10 577f9c75-1157-44f4-82c4-a49639b4e358 cf19e2b2-36a2-46b7-aec0-4ec2963c1cb7 61dcb172-1107-4d43-95b5-9e8e3b580124 d73ce487-9276-4d8a-942e-0d1ea4d30ae2 f52c114e-4d29-43fe-8b83-87f88c03b704 9c1b0aa5-4e09-4da3-b162-f7d9e06521c5 f72cd3b9-98b5-4aa1-a07d-40e529da939f 9e90338d-f7b6-4871-b18c-1996c59c87cf 9ead460b-3127-4c21-be7f-351e14e2365c d447fd91-442f-41d9-b1ed-d3789851c004 902cc1cc-7ab4-4056-a70d-002e5aca7771 d1dfba75-f50e-4e1b-a123-4187c218c5ba 72181e6b-8300-4ae1-84e0-ce6c9a0af6b2 00e4656f-ba2c-460a-be91-110520e31573 5f3bf544-856c-4562-8cfb-148e4559cc01 d468aa14-f7dd-43e8-8fdb-1a0388191290 da028f12-a984-4227-9a9a-1a19d8a1809d b97656e5-d769-4691-8490-78291888d736 ee6a31b7-c366-4a01-abaf-75f1e56b537c 07f58955-43c7-4dae-9149-8392e563921a a353f390-f7e0-4568-9d55-04d43539dfc3 29b332d4-d435-4e97-a1cc-1d853ec0760f 5774ce9b-6b02-4fbf-a298-9ea46d5c1541 ef0db988-abb8-4a36-b95a-4842715309e3 655f0ae5-9299-4461-99bd-19a31be9307b ca96638a-918d-4b73-bd01-d80858e336af b30622c7-3667-4d78-85bc-6558caf31ba7 1319883a-1c83-4211-a163-ef9c576a246f 52b619ac-63e6-4c7f-8094-8b4397160f49 50a7ddee-8741-40ef-b69c-9f099d57902b 46d74b44-77bf-41b2-90ac-525193f8388a d6019d19-f197-49f8-a146-178115d25626 c6b1d26e-a21e-493a-bba4-9980cf153ba5 4ec4f460-ff8e-4861-85fd-5965dfaa5a67 5c687110-70be-41b8-a6ed-9f3157878708 93058f16-2526-4344-8287-a8c080dc08dd 88b49c31-6843-4cdf-8263-af116842adc5 d6787c37-d4f2-4581-9d7f-f3078ec4812f 05c69379-0ddf-49ef-8236-ba0788387de2 04901b81-c513-4c16-8d3a-71736be1659e e56fce2a-00d4-4489-b447-589df9fe56b8 1c49b06e-7909-4254-8d54-f8646014b5bc 3c7525bc-f12c-478a-a6ef-bcb9966c371a f06cdbe5-a733-43de-8780-c1610c9eb623 e3e2944c-8d7d-436e-86f7-0dcf45f501c1 41cc0ce0-9b9f-4439-afbf-8fa1b714ab99 888c7e35-070f-44c7-ac6d-c17837394988 53824d08-3a87-4501-9100-3d56c36c5df1 d2db2a71-1627-4487-b2d7-a078eb3cfdde 841f823c-b01d-4f39-a6be-aecb29e2f90e 2e44d472-df91-4a40-99ee-a51a52faa6bc 522ea1c1-83b2-425a-b3d2-3af3910db2cf de0cfa2e-dd57-4e24-a643-1e9c04fcffba 1b2c7041-8946-4013-84aa-ac3048466945 9979fd34-8b38-4fed-87d2-0495feaf6fd3 58f95205-dd29-4d60-9cce-0c79a493e95d f72a7385-699d-480a-8761-43cdb97c9839 852e4c86-6c93-4c95-b31b-87f012f2a0b4 8ad2030c-e1bb-4f2a-bca8-502ad8d44448 3d555252-d0ce-4799-9ffe-dfc3837ceccb ea7cf3f8-d2f0-4599-b984-e247f4216f91 1f163aeb-d309-4e75-9ff3-bddcc8421118 ea9978a2-e7b7-41c2-9373-d42a1b5374e9 9667bcec-92ec-4ac0-b146-d6741979c58c b6815ce4-f7d3-4a8a-a4cf-7e5a32d56a6f cccc70fd-583a-422a-b015-f64cfbdb6e91 0c6a128c-17df-4be4-b3e7-f46ee6d329ea ecb9ee22-72d1-44d1-9f95-cc772da70081 954efa71-0e09-4b70-86d4-a9cdf838e611 cbe5d1ef-64be-4b44-a162-68f69f66ed0a 1fe935db-e6c3-4310-a31f-1798d11c725f 157daa55-42df-49ba-8594-5daa64aef074 44274f40-1e78-4122-964f-f65543f13a1d 39d5caf5-5c30-4251-b82b-afce932ba724 68dc78e4-6b6f-47c9-9bc0-69cecc1c41ef 7377d41f-b97e-44ce-aabc-189a38e18ded 288a646d-d7e9-4dfe-978a-16c71474920b 8e616642-2839-492d-8768-65a06b2719eb 23fb6184-9f8f-4864-9915-4bd57209bb90 2164ca10-171b-46f0-b874-88d1a9e51c5e 79dc83bd-c311-4fb5-859b-49d05c68c35f 271768f2-4710-415a-8fca-6da7a8aa86db de11121f-6511-4072-aae4-ee1e5b56cd66 abf6fe89-da44-470f-9ab2-a7dfb583dc34 c62a9eb7-cc29-4ead-9c53-3f454e0693f3 f0a36d32-8c3c-4765-a0cb-9948b510c8d6 965597cb-ba67-4fc7-b82d-078c87d1f1de af7dfeda-7855-4b04-bcf5-a6101f73a74e 6684febd-52f4-4773-920d-3287b6b5f413 08b695a1-a5ea-4a38-a4d8-a7eb982073b4 8b4b11ad-94c6-4e39-9e72-4640b8e9a8ac aafeaff5-578d-4d97-a8b0-e5686c3283ad f5277ae8-6617-4609-a677-7df2e4ccc8cb 6a23e7f6-8646-43dd-b156-435d8d24987a b16eeb5f-07f7-404a-b256-15e9d07e5ef9 a6322680-f6f1-442b-88bc-6f46abae3e8e 3d844f19-6f86-43a5-83c4-ec10e18e51da f3c0e29b-4f89-46f0-bbee-cc13f2d6e34b 4c32b023-528d-4295-b60e-18f6104fa64f e3ec281e-3d99-4bae-a6aa-e88bbffa016c 423e7ee3-64cd-4b1f-9eff-237c426945f5 3934328e-a9f4-4825-8f56-323d56daea42 ed552e6a-f52b-444b-8589-41a49369a94f 31e07434-eaa8-4b8c-8325-9dde6730cadc 0ae4ab8b-225e-4f25-9072-2d06479960e9 09be1243-c98c-4052-a6ec-fced4e5acf21 aa97400a-b1ba-4889-b65b-7d68fa00d866 7db1a28d-f8a9-4505-88a9-a2ca50db6dfe a1b2e42b-be96-42a1-a1d0-3ce09d3ed32e ce18cb06-603d-4937-9e31-903617ebf6d7 219b987d-2e98-4c90-9ff2-d12f7e45133b 7348d9ae-b589-416e-bd7a-850d621a03c4 5a4d2cbb-32f6-4dd3-b736-d41d63a54e28 78eedb0d-1db9-41d0-b2dd-4970c20b1453 98470899-c224-40e1-91ab-928116e3be21 37467e92-e096-4edb-8443-e6cb57da46f6 9d51c67f-d961-4c62-9ece-8f87e9c78989 c03796bb-1bd5-4146-97c2-631a68735f58 9624bfb4-ea07-49c9-b7bb-10fafd87553a e71ac0d7-0ff8-45f9-b2d4-f4e72b989b9c 7f1a37cb-cc34-4a2c-8ea4-9bf8e9c01518 5676724a-e379-49b8-ae54-be6b7940475e 3e9dc679-1c74-41d5-abf0-3e3d339ab6e2 efa82a8d-0501-482b-87f7-c70149f3f6e9 f3cafb7f-3ab0-40a4-a4bf-730004d0353d f50821ea-c16b-4b01-9c77-8efcef7de622 52ca5157-a884-44bd-8f98-2721565e30be 9f899f71-f281-4f28-95fc-d8bdfd0dc581 6c277ded-4956-4dc0-9b6e-03fa02d6452c 443a3071-3205-45bf-8344-1b7b00730e0b 70e3567a-da7b-49ea-82a9-4f7aba5a14dd 1e533668-1a02-446d-a6e3-ee3449fa3a91 d7610e5a-8065-481c-bb49-7086956bee3b 073994c8-1704-4b75-b1ae-ed239f530ca5 fb629ba2-93b8-4c9a-82e2-bb9e21a53a08 710143a1-5f4f-4859-b56e-9ea8a18a5727 ea371446-5046-4164-9912-bed091dcdde0 cb0ec791-32b0-4063-87cb-dd1c0322a3d8 4e66b5fb-db59-4890-9e00-57ed7915cafc fc58cee3-c85e-4c36-8501-d716b3f58b2f 37797207-4dc6-4568-9ad0-81430e714f85 86202b52-2332-4d98-a5f5-48f47426336f c04173fa-ce00-429c-8d16-28cd50935a94 4e752898-86f0-4d0e-9f69-e55f404fcac0 dac4ff1b-f73f-4669-b560-800abb93fcb5 7ecb27b0-58eb-45ca-9925-df187624bac3 94342881-c73e-4ae8-b59a-dea13b6a00bf 17118a08-82b3-4eac-bee1-519eee6ad3b5 f771b9ef-67ea-4537-9c7f-2c1a4818414a 60863b1d-e621-4866-a8fc-ca39edb8800b 7bc1adf0-be4f-4278-b342-e4b8963b8766 7b98d208-38a4-414b-bf38-09fcdf3bad54 308d7726-08e6-4391-90c9-fe3b8e6ff8f5 1d6ad5f1-620a-4072-a6ee-da777e4c48b6 2dd0331e-1705-4bd9-a1fc-01cfb0b11d70 49e77761-41c1-42b8-9363-246f087d9125 7f08af22-8217-4b7f-a96e-1ca02fb3ab83 5fa579ec-49d0-47ec-a819-d81d8d971df6 17450a0f-9765-41ea-af4e-05b5bbaf3530 4012f5e8-483d-498d-b2d5-47ce584488bf ffbc57a2-e8ba-4171-9faa-c918a692fd0a 4305ee9b-a1c9-4633-b864-2b49ab3f12cb 64de797d-5883-43b5-acbc-c4e70c8414e2 5ed84923-cb02-4fdd-b3e7-06904d30dfa6 94a712a9-2d7d-456a-bdcb-e555d2e5294d 7f417962-6da6-49ac-b1a4-c9ce9bc0df15 8d47e249-40aa-4276-bc0e-ca1589a47c99 7b6c7383-3095-4c77-a9b1-6f9fda711b9b 78050c57-3810-45e9-a4f2-b1c0c8b96b72 40d2a15e-458c-43d4-862c-04931e31ca6a 36794a23-2d74-42b8-abfb-9ae65589a30f 2427c7e5-3b8f-4119-a2bf-5bee96726192 5daeb60d-0a25-42c7-b37d-f5647ac9dde9 ea4f90bd-b380-433b-9609-7e50225038f2 eb20eb9b-53f2-4cdb-992d-e44a7f3fef2d 74a1c48b-2519-492d-8cfb-dfcf7b25b2a8 a7f29d3a-7738-43cb-8e6c-c7ec835453eb 040162a8-ce73-465f-be9f-0dc87e9fcfbb 1ce03705-a15f-4eaf-b395-8a33ee033be5 2be7a65f-0faf-463a-b1aa-4ca25750dda4 a421eaf8-267b-4f76-ae92-d8612844540b 1b48b287-55a6-485e-afcf-1d3d481e5f67 728cd6e9-b3d4-45cc-81b2-6d2436de39fe 135bdb0e-1a6a-4350-9804-d24c08b948c4 9826f1c3-ff92-4df0-adbb-44380da759d8 70fcd3f5-57ca-47c7-8a50-e52bf42672aa 61a00a29-a1d0-4f54-af16-84e4c6fffbbc 557f1005-694e-4418-979a-8342f022bd15 87ebf7c4-4749-4ca0-a919-e6f5aaadafff 0b05a569-ca59-44db-a927-2adca374070d 113c899a-746c-4974-990b-6cabac7855df c6ab68a7-a582-4705-9afe-f619b7de3d65 9c04d620-565e-4e5e-badc-7eac802c90af 0fe8c248-ef7f-465e-9d3f-2b5608d6e68e df88470e-a782-4f1a-9f90-bd84347b04ed c6c0277e-7189-4a3e-9bcb-8571f8ad7a43 b93e22ad-c9db-4a81-ac39-bb1592232c25 1259509c-3a81-4c09-b2ba-988be78fcb7b 27bffd8d-cdb8-47a9-a6d6-3426d7695539 c396fd1f-3eaf-4a32-91f7-01ea44bab066 a591b14d-7ef4-48a2-a393-c6b5f55be339 5bad989e-7ea2-4e77-a967-318560ffd453 fe9897f7-e793-4991-8005-cc10aaa763ba 97ab783c-0960-44d0-a74e-8a76a53120f3 32a7a49b-f8b6-4291-8b08-3f5e47d30409 43a8c3b4-4d0d-487a-9e2c-7ab88e960d4c ad298000-8e53-49e9-ae9c-d258c5bfb372 53b02e54-7262-4ad4-8755-06dd2e1fcca4 b619d856-aa07-4e83-a7f2-4c9f62e691f3 97a6db07-200a-4169-8d78-c3305263f355 1b851ab0-f3f6-4a46-8d9e-22149ceedc58 831590e4-c9da-4685-9fcb-2e8fad7af5eb 2f96ee5a-70ae-4ed3-b99e-68a274bcd7bb 798e1020-10b1-4a6e-aab3-74fed3eaa129 640f176b-b3df-4515-8a46-1863bdfcfb09 40a4c01c-f9be-409d-a0eb-6f311b25dca0 2e887322-51e7-4dda-b358-5f112235d784 1b738bcf-7879-4718-906a-f27d24ef6b84 748498af-f676-4b30-87d1-6bd6e417e527 bb7c43ad-f516-48d1-8bdb-5038e526e0ec ecb242e8-0bf2-4f3f-813c-9ba7fc0ee033 94d4ad21-70f6-4e9c-9cf9-c7987781d2e6 3282b6f1-2b6e-4f7d-98be-db33df78be83 5db3acc9-a34e-45a1-a2e4-1e0619ad8aa4 27df7d41-023d-48e9-8169-c36c4bf49761 3bed23c5-ee5e-4985-9846-7884dfab41c2 d11a9ffd-f6a5-4c61-bb57-82e0c04ba5c7 67f4ab19-57c8-40f5-a6af-98e97f1a05f9 8bb8d344-993a-4d16-a82a-f5accf5b2530

## 3. Inputs and Contracts
Input: Profile metadata for Get-ValidExtensions.
Output: Script execution status.

## 4. Execute
- Write Get-ValidExtensions in export-chrome-profile.ps1.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "Get-ValidExtensions"` or `bash -c "Get-ValidExtensions"` depending on the environment. Expected output: success for ExtensionsExportParse(PS1).

## 7. Done When
- [ ] Criterion 1: Get-ValidExtensions is implemented.
- [ ] Criterion 2: Linter passes for file scripts/export-chrome-profile.ps1.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.

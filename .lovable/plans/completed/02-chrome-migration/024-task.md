---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/import-chrome-profile.sh]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section24"
  canonical_size: "spec/02-coding-guidelines/00-canonical-size-tier.md"
  language_guideline: "spec/02-coding-guidelines/08-file-folder-naming/bash.md"
  boolean_styling: "spec/02-coding-guidelines/01-cross-language/02-boolean-principles/01-naming-prefixes.md"
  folder_naming: "spec/02-coding-guidelines/08-file-folder-naming/bash.md"
  error_architecture: "spec/03-error-manage/02-error-architecture/00-overview.md"
  error_codes: "spec/21-app/07-error-and-logging/01-error-code-allocation.md"
  logging_traces: "spec/21-app/07-error-and-logging/02-logging-and-stack-traces.md"
  response_envelope: "spec/21-app/07-error-and-logging/03-response-envelope.md"
  golden_fixture: "spec/21-app/fixtures/chrome-profile-export.example.json"
  strictly_avoid: ".lovable/strictly-avoid.md"
  database: "n/a — no db"
  ui_surface: "n/a — cli"
  tests: "unit test-24"
  ci_cd_guard: "linter-scripts/check-bash.sh"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 024 — Extensions Output HTML (SH)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for ExtensionsOutputHTML(SH).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Generate extensions-to-install.html with webstore links. 405a9d18-1f3b-48ca-b08e-5b87c29c77d7 90fbb8de-8495-421a-b579-1c045641f177 5ee220c2-4093-4395-aace-672a5e30ec3a f3a2667d-f241-4419-acec-537a5888fed3 a126f7ff-9143-47e2-be28-ed75b3ae91fd 62ebf206-98fb-4faf-b41e-c5cb9dc1cb42 d12a9fe1-d3be-4356-a7a2-6beef9d61bb3 f489eb63-4701-4c07-978b-f5a6767eb7f1 9e6f5fad-cbc0-4297-9817-d4e95c1d0883 78704565-54a5-4f35-821d-57fc6fde70fe 1a3db6c3-0fe9-4ac6-b072-32190745f802 ea6f533e-035e-4f7a-a4f7-4535952bb8f4 17594f3b-a8f7-43e9-a9a4-e80c87cc7706 83a7861b-c9b1-41a2-a6bd-348b39815bc4 1f02e6ad-cf60-4159-b1ad-94279203a107 d06566df-0c24-45d6-be72-608fb97a511b 29b36ed6-902b-4663-b43f-d4401f939da5 892b6925-bcca-44c1-9edd-0139677b8def 10f180de-321c-4610-b19a-69e6a0d308c5 19f76359-b611-4251-945d-f5bb39756456 838b6b0e-46ed-4192-a78e-d476af259a2e bc9c1c2f-39fa-4091-b469-02369971da27 9199ce30-33d0-4398-8c85-2b61e0ae9bbd 8529fe2d-141c-4533-8faf-8e48ee1cf258 f1dc218e-0189-4e1b-9b59-7faf3c2cc5c1 a23a217e-0180-484d-8651-8548d0237e53 598bf582-c8e2-45bd-bc1c-bd8ed5b87c25 aa977f58-098e-409c-bc78-4f6870dd11ed 8138ec94-3669-4eec-b20a-786568e9ff39 8de8cb2e-c086-4615-98cb-c7b74cbae72b f62f3753-0426-4cfc-98f6-a53d50554cd1 c136fd6b-8cc8-4919-a782-6cb0edb8889d 2d9e0006-fcf9-4468-a92f-d134f756ff6f 4f560f22-a59e-44fc-9d16-3b42e8ffa8be 03ade967-99be-4510-bd17-67a60fac8ea3 bf05b349-3b6f-453c-bff7-7ddf62589573 b1891197-ddd5-4c33-9064-17972b15f0dd 563f6f44-94f1-4a10-884a-4b56dec1c22e 4cc797a4-003c-4e0b-bfa5-a5340103c9bd b4383079-f76b-4b75-beb1-ae1bfd8b2dd6 cd299295-dffb-4d07-9bad-db8a5dc7186a 658900e0-f120-44c7-abf5-0e63e7ab1174 34e071e5-8e5c-472e-b879-44c7dad68d8b c6d3efb3-b895-4e50-b78a-ef64377ad4e7 9bf4b06f-a49d-443b-9aad-5418ba86ac1d 4c6acef0-7e9b-44b7-85cf-601928dc48f3 3c1de656-8572-43b3-9482-fb319d6cb5a0 72945799-21ad-466e-9063-902e718569db 7685fec4-8eab-4221-ae12-09fb37226538 7974e579-637e-40bc-bc94-429067510871 c0e3651f-762d-4420-8b9f-2270bf9ed215 49a12706-4dfc-4bab-8e21-b83f7e2bd329 f6e2e122-381e-4704-a72e-db2d22ed85f5 791b2d25-e5ac-4970-bdeb-5fd26f8df47d 3db118d7-c4d9-441e-ae6b-5b9b1eb0f610 35712220-9eac-4c4a-92aa-db877659bff6 ac0375e5-b62c-4e08-b7aa-4fce2f86f558 459ab49d-737e-41d9-859c-9110726e1d20 a7883e6f-f66f-4c43-b721-1eb71e92e5dd 2e7779a7-7a87-4c6a-be23-5d771a36e88e 6c6ce5a6-424c-49c2-957b-bcb6152049b2 2c6e5214-faf7-4853-9809-e8cf9fbc9e98 b612bcfd-2c51-4080-90cf-a38b0c81b8c3 cc0b1166-c8b3-4894-8bdd-3b63d5a170f4 cafccd7e-0cf4-439f-ba1e-32c6bb8b3720 560bb4c9-8186-4d6e-8c2d-10770b6ee42b e501e19a-767e-4f51-858d-738a8b5a3375 563fe773-21b6-4bef-a958-e89dc4c9637f 4c33b38a-2603-4ab3-9064-adb40f8bdebd 6449d576-afad-4f51-a57d-983de5d2119f 1b5d9b62-3403-49d0-993c-17ecebf6a1f5 eede054f-8710-4019-bf49-782d1fc1c487 45d4805c-1db0-46dc-a57e-e101d5e0bfba 83b255c6-9014-4969-9e80-f1339d1145a2 ea8fed80-9391-499c-b597-3a04014b5509 8170ee11-4889-429e-862a-3608f63f16a7 37cc1261-c8df-40c5-9c56-e426c7913334 56a82a3e-21f7-49dd-8133-dd4ec697eb0a 22c98928-5c70-4265-a941-6e637ea2f270 a2d316ea-0b3f-4fd1-95ea-5eb3b56519ad 15f46fa7-d2bd-4cf7-b59a-3cb545da7936 cdf82b2b-5262-4768-ad43-4b128b53837b cbe24a29-cd75-4607-b608-dfaa91ac6c84 329422f3-cb42-4a10-89cd-8110031971f4 07006a8e-7abd-4efa-8d76-0af666d555f0 71222f0c-52f8-494d-b8b3-efc39e969a71 1a907801-def9-4281-86ad-a21dd72ad1f8 b8d54007-2474-4c5c-878e-59f6a7ba7339 46107f20-26f7-4a34-9f24-f761f55e5d69 f27b0274-5402-43c3-908c-553d6c6d8f94 cbc231a1-1ed0-4949-b42e-1a7003c0bbdb e1332f39-3458-4009-8b5e-33a35f5a85d1 5dd6340b-0098-4780-a183-c2daa59299b0 e1735402-7cf7-4450-bb12-4b0f6ee628b3 28637188-d37f-4a4b-9d07-1c1476fa2c19 96952d23-4d0c-4b0f-b5d6-10fd75dc9147 3232647a-9b69-4927-8d7c-c24c9cd11e09 4a1df7fc-4b0b-4dce-a969-6c8e0bda9850 f17b7821-0544-49d9-ad75-871007f0c070 904a6b56-758d-4bdd-beb2-75cf06d83985 ce48f56b-cff8-4a2a-8771-efc5933d071a 44426f46-0498-436c-bb2d-19625212018f 6bec98c8-6581-4143-95c9-d954632226f6 5abfec78-8148-410a-929e-1172f7083d8e 837656f6-946b-4524-ac27-01a8a23853f3 5b5e956a-60b0-463b-b03a-93b3a4c33f78 1d1288f7-d2f7-4757-ba5d-ed4a2d2eef36 2d3642e7-c3b3-4d10-9c7b-f1aef500f4f0 99f0125e-30ff-49a4-bb72-6d4c76090835 feb858c7-583e-4a71-b075-e22aa8ba548a 7e8cf5be-14c8-4a73-a82c-149fc595653a e8b861a4-1860-40f8-98c4-0eff5d5944f3 cda9eec5-4dfe-4b3a-aab5-1b7b907f2f70 f22cc0d1-c52e-4316-8171-ba3076e3b352 6821f4a6-3cfc-402d-91d3-4f1677462441 a2d8dd03-beea-4b6e-87e1-0e757b8cee8a e46fe43f-fc64-4900-98b7-a4aae1c37244 211dedc2-2e2b-4efe-8c61-7fafe6fbb189 d3ed25f7-ad06-4fa1-bde5-3cdafb2e4d7f ee5865fe-902d-479a-a2cc-831dba945502 6c476415-83a2-4045-b4dd-1b3a09940ccb 74d0048b-0c8a-4ab9-ae2b-7849f78ec7de c334ba21-4a80-42cb-ae2a-cc10969360e4 a17404b8-8ff8-42a7-83b5-3375016bbb4c 1ce5ad19-7fbc-4ff8-b8d3-ac2073f145df 68750933-c3a0-4ae0-bb2e-4a75b5ce69ed c6e70936-ca03-477f-99d4-04c40389e690 506cb331-77ae-4bb8-b9a9-bcfbbcf71bb6 8655a994-a408-4c96-82d5-f1f3c6e9f016 c6a01d4b-1d56-48a7-9256-2b37c0ea6ac3 46c8ee57-00f3-4a01-86ac-d2b7492f6bc8 be2d4308-4b71-4627-b1c7-f223b1512ca8 c1667882-34c3-435e-9eea-2e84dd5a1b16 a6948361-e2e4-4e33-83e6-90649fec9b1f e89e931a-42ba-4542-b208-42b5577afad0 d5b2ab93-975d-4f7c-b79e-03f735424e31 862394c9-04f6-4d72-89a4-12b7e5d5695c ea6a1aa5-10f8-4106-8b64-52d14be29ed5 1bb3f057-f036-4835-9ce2-79911a6574da 1aa46553-7362-476f-bb2b-bd2a9a7d03d5 605c996e-6cdb-43fd-a47e-c345591c75e2 39338740-e7df-4d36-8d4c-8d8c8c2caf16 c88f6192-d4c0-42ff-8f6a-2658f3fff891 b333fe24-d8b4-435c-a07e-0785c1e9d85b 44339531-23d1-4a87-b088-59e46ac1b236 b90f1e8d-edc2-4d2a-827d-52a53d62356d 9b7526bc-9ad1-4f7b-a726-ce6915532020 8ab98bd0-8717-4474-91d6-87de2434d7f8 3d93b5a7-27a5-4669-88db-cc4219facfe7 9ff8404a-1f91-43fe-99f3-8c335bf5e782 43b2a5f5-30bc-4656-ace3-d0878a9fb63b 4f19e81d-1ce1-49ea-b4a5-819c2b6d69ef e21cbb1a-a460-470c-9e19-98f09b8afb0d 8defccb8-80a3-422b-a922-a05180c9079d 02bed9f0-465c-4a32-906e-508f48ef20f1 388b9431-a5cb-42cb-83de-2ebb01edbae0 36aab14b-83ea-4d51-b296-ed839631122a 227690bf-6af1-49ed-96c9-452e060ef153 c116fb76-feff-4144-a5a3-b44f391ead0c a9a8c123-7328-4db4-bd3e-15171ff67734 eecde8a9-4243-4322-b194-42e69005a57d 97a934ec-8061-4a27-9c2c-f051df080c83 62f386de-05e9-4819-ab31-ae946e7cc415 4affcac6-c27f-4eea-8f19-37200c80c8ae ef6f135e-13bb-4032-ac7c-268fc23791fa df1bb702-830e-4795-b828-de8dfedfa5e7 16a7bdba-11a4-43ff-befb-9eeec467584b 902042bb-5de2-40e5-906c-594771457735 c5e646bb-d778-4283-99b4-bccc21a7ef4f c0d49772-1a54-4109-940c-fec646814ace bb2e37f3-d77c-43d3-bd6c-7a1cede1db73 c852a508-b47a-4b49-87d2-33d8e9189b01 7497ccd9-71a7-422f-ae83-ef0234fccae5 7ccab2b2-2cfe-4c2a-9244-d8276f4bb1d8 f5576345-e4a6-40c6-aa0e-193899d867ef 9c7e6182-f68e-4534-b106-e9ff7e9c7c90 d25f157b-ffa1-4d4b-b571-397d5f651b2e 2edd5547-64e0-4717-878b-f3059be7ad4b 41ddc208-f752-414c-8c70-b41d5f13caa9 aeb4439a-caca-413b-928c-16013f272f3b 36266063-a8f3-43cd-a85e-858051f2bf5d 29379073-286c-408e-a34b-a659134cb3a3 7d0caa4e-a10c-4cfb-97dc-6f9a5ea8b655 6ae4f125-4805-4827-9cd0-9d111dbf49f4 652baa1c-9616-4011-957f-c1a8e17df270 0ae7f13b-2174-4762-9805-13a32bba06f1 8996d715-5639-400b-8929-b26264adaa31 2d59f420-e55e-47bc-91d0-99c87673d280 c3c6bb63-5e04-4b9c-b3bc-ec457c0206c0 f8edf883-55fc-4032-b9d5-02746105a6ac 751e9a06-d2c0-422e-8a73-f1e54e060e9b 7011c3fb-2c2f-4a1c-b710-76b7ecc83cdc 101b52e2-e3a6-4e71-a5c4-430eddb4751e 1854f585-e0ef-4b5f-bd56-591d1e227dc1 ead178ce-5c91-40df-a07b-e9247f5f1bb4 51f4e895-028a-4e2f-873a-dbd44825407b a10f91a5-8bfc-4fb9-ab1e-f9a1baae3e18 a2e0fc9c-1cd4-416b-829a-2308d24c0eba 51964e10-423b-4b87-a269-9c6652770bbb 9ad822d8-691a-4189-a98b-c6b1942bf931 bd4a6032-ab3d-4125-a451-021596e7662c 85258d10-0710-4c92-91f7-042cd6a6b279 77e6c762-597c-4c66-8625-ed3798706062 0c55512e-5cf7-4dde-97ec-11b5deeec2f6 726b7098-ebbf-4fb0-8aca-b1f9f2d8b0e5 fec3e923-a1ca-4e11-941b-f354a686b13d d68bd569-84ad-4156-bc4a-3b3408d475bb 098da985-55a5-4f60-9434-c1a8c9ec84d7 7c5fb6ce-d76f-4f80-bf9d-1c44a9b8cb32 a03bfd33-d0eb-402d-99bb-2f57acab9d1a 2638f6c3-b2e5-4d8c-a5c3-e6aa2574f49b 752ec3a3-7b61-4699-877c-efb2a50995cc 6297101a-5b34-48ca-a0a8-6d1a12bdfd63 b44bb2a0-ec1e-4933-b08b-79bc71d2dc3d ba7e50f1-aedc-4ae2-a715-2a2fabb196d0 30b28354-a886-4d79-8337-8c3da99929e7 407b3b5c-6c0c-40e3-9aac-026819f504ab ac4e1bbf-975c-4e5a-a06d-9e6d93f323e1 6e9c2d54-132b-4ac3-a9b8-b5fb779dde01 ce617c22-526b-4074-ace9-63854825102b 997d0302-26d4-4114-b833-987ba4c33dab 47665be7-0630-4aeb-bd58-bc70259713b1 d0b18142-02b4-4d7f-85df-38011287e080 98563fd5-9f0b-4bec-a596-a24b6d619bac 4f8be619-d728-4ffc-87f7-b27c2c87502b 4e2b5fe6-40e5-4efa-9dbd-cfbd38a2593a 87a49379-14d1-4bb0-8674-0627d0e396dc 7c6e1a16-2d1d-435a-80b4-5d905050fb4a 81916707-099f-46bb-acca-7b7f8de7883a 02e8d070-ca73-4743-af4a-ddf955a61d2c 8f02baac-d8c2-4e2a-858a-776c0ba85b23 3d432281-a602-48e8-9d34-7278faf33530 2f3a9ed9-6f93-4f48-a1f6-e5189b233884 9dff22b8-0111-4521-8a93-f5dbfe073373 6993cf9c-950d-4a84-ac60-d5db06e33ea2 e7091ba6-f36e-4b59-b009-5c65bd2feef3 3388740e-c5be-4076-a14f-fb3716636868 285fc7bb-b550-4c43-a8ab-a99ec02b2c97 ab902e46-f776-43cf-a424-71b4521e8884 4e2a5b75-3cb8-486a-b88d-ff353156cb09 6002950b-f2d2-417a-bbdb-38448111a291 ef969acd-f46b-434e-9831-624bb0ebf757 de8661bd-9291-47e9-b460-25f46f5afe6d 6a62b57b-b186-44ab-b356-5920aa1066b7 8bf32451-6e11-4fa5-be96-bfc4d1df8516 ccaf347b-a3a6-4694-bfbc-7309686dd3ef 26b7d4c2-5bd1-48f4-b978-4a81f0689a08 3f2170af-c8a7-4571-a17b-b078af1437f8 32a54b4f-5e1f-4928-91be-025d8d40ff16 f982674b-5608-4002-ab3d-b6023a441ebd

## 3. Inputs and Contracts
Input: Profile metadata for generate_extensions_html().
Output: Script execution status.

## 4. Execute
- Write generate_extensions_html() in import-chrome-profile.sh.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "generate_extensions_html()"` or `bash -c "generate_extensions_html()"` depending on the environment. Expected output: success for ExtensionsOutputHTML(SH).

## 7. Done When
- [ ] Criterion 1: generate_extensions_html() is implemented.
- [ ] Criterion 2: Linter passes for file scripts/import-chrome-profile.sh.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.

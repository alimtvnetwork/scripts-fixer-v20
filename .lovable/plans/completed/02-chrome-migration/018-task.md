---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/import-chrome-profile.sh]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section18"
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
  tests: "unit test-18"
  ci_cd_guard: "linter-scripts/check-bash.sh"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 018 — Importer Process Check (SH)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for ImporterProcessCheck(SH).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Refuse to run if Chrome is running (pgrep -x chrome). ce8b37c5-5201-40ad-a0eb-5ff2210b92d6 9aef52ba-d6b9-471c-a91d-514d93db94b0 7ef3e954-2f00-4024-bad2-639304a3a48d 9f750a95-7b31-45de-9262-1d98cf41a751 9247eea7-8011-4721-bba7-56b625dcc78a 92b366a1-6b52-43cd-8707-0d68fba9505c eb88130b-d0c5-445d-bc76-3f132187743b 71478a6c-30f0-4295-ac84-fe7140f0c1eb e34b2743-fe46-4c05-873e-1d81da74723c d0112bd7-614f-4411-87cc-938cfad837c8 78088223-b005-464c-a642-9bac99b142a5 20b5cfce-237f-40a9-a302-97a82b215e49 cfad1daa-e76c-4837-b6ff-b3a19222c187 211028a9-71b5-4e53-a73d-ca35421b551a edfcfdf2-42ae-4de5-9703-a5d24e461940 ec0802ee-1bd4-4c66-a687-c907c1955931 725acff5-1c88-438a-a19f-ea83ba9d7fc6 40a08acf-728b-4f9f-bbde-b4240b192c6e c8c07da3-ee10-49e2-9685-a65440f3c2e2 a02a42b5-205c-4d8e-934d-bfb436fda284 861aed02-3a51-4e87-b8ea-7eecf07fa025 9531bcaa-ac9c-4dee-9a40-ca57860dc1f4 ea02ffe0-ac0c-46fc-9b6d-7225a7e4c784 0d6b415d-6532-457c-910a-cf8b5dc2a137 118e2b07-6af8-46b9-ab90-cca4274d4aed de90ec02-1210-4006-bcc6-20df03ee63a1 7452e9ce-a72e-4e7b-aedf-80bc9b785b1a c205af45-e2ee-47c5-9d7c-eaf4518d30ca 59b83f06-a54f-4af0-8147-baae22ffd86f c1756411-6129-4fd6-9661-e9d05dc6b776 7905fa68-956a-45fb-899d-095ecc3e582f d4a4db69-3473-48f1-be9c-c8ae5dd7cd6c 5a1bb3ac-a02f-4ac7-b1e3-ec9ba1f2692f cc77e63d-d9ec-4367-84db-aa1914169846 f149745f-a808-4f5e-b7f9-c863539c104e 7d8f5b68-6ba2-4585-9b07-3a0259618b21 73754e88-5070-4084-b6d0-dc2099ac43ac 09cb6095-9e2f-4123-90df-28d77ab37021 bc29c197-eb77-4244-81e8-66fa0a966d2b 51c5331c-dac1-467d-8919-d866b4568449 b3f802d3-29f5-47b1-ac2f-568cd378022e 9b08da63-4db5-4e41-baeb-41e2a9cef1cf d690b95d-7798-4b58-b75d-491a6ea1d833 14e78de9-7ae5-4dc4-9020-4e1e01193532 68f3d933-5637-4026-8c53-c99126477f55 61f29b2d-3809-45ed-8d58-6b57f86a77ad 750d6a6b-dcbd-43b3-92f7-74b138758c5a 5daf5696-6a5e-4d9d-a8d9-6ccc25b7e1a8 6ca44d7a-bbc1-41ef-99d1-7a66544fcfea c926df1c-d655-4af7-b3c7-ee2f5067d118 46450529-5823-4bf9-917c-c01ed4ee5b6a f428087a-8360-43d3-8007-e98eb3893b97 8ca68229-3cff-4873-bcb5-c0e227cc451c 11596f11-3373-4648-b8e8-ffb238caab4c 38a3b628-2c0f-4ac9-ab43-1e2c31a2b716 444a78bb-46e9-499f-bcda-ee9804c07cdd f2bd1bac-5481-49d2-b053-8eaf3b3e80bb 2a8d9d6e-0306-4ace-a2a9-59cbd2c554ce e053689e-3a06-4ad4-bc03-6a24c3ff434f bd9e8279-00ea-465e-a0ea-2b58030fdee3 14fbf916-6c88-4295-bb37-ebcccec443a5 c5f4174c-ab46-414f-a917-a74cdafea14c 6a3a3a55-e409-45c9-b5b5-34349279ffd6 25fcd7fa-8f60-4b1b-9b09-f212b79da855 3d28c856-c349-49d0-b9fd-303b2ea4fcc7 cebdff95-6930-44cb-a104-f1f1d791d8f1 0f3c7831-31a7-4297-b8b2-4c00279147ea 7c8338af-295d-4d06-a11b-8c6283a1ed65 cf119953-8cc4-44f6-a14d-4f1bccbaff07 fc88fb3d-6f08-4a13-bf64-5eecd0ba74cd 8dcfbdb1-babe-4809-b89d-ad828ce2cb25 b8e62200-6e90-4a4b-8e31-32e654c2f0c0 d105c153-b662-4e19-8785-1fae08a97df0 6c052ed6-f169-40e1-86c0-f6414216c3db 805b6668-58dc-4525-b5a1-91c34493fa0b edb1cfd5-3646-4d2d-8f71-f263807d5f5f 6f2a6eb4-1fe1-408b-bad0-d12e24357e97 e479c01e-1554-4c47-b905-104192449f06 9c26e09d-23f5-4194-9a34-e33f86976f24 4cae7aeb-bca9-41d2-b7fd-05d57649248f 69e53e89-13ef-407c-adb6-bfa7a485de50 6d39e37a-bf6f-42e4-9c1c-ccd70405b230 e221f662-2976-4e14-b519-24c47349ab50 4bc11e8c-d9c2-4f6e-8fe9-b514070dfa25 680dd479-3f99-4c11-abc2-f77bc592dc34 559d0db7-173b-4a41-a20b-1050e1406e40 f8ae9af7-f7ed-44b6-96e3-d78edf4e5694 f9604a04-96f9-4a97-b32c-340315357a07 704aa41e-b2e3-403e-adb0-3689de79a248 e8cadcd7-dcbc-4f76-9a9c-391f6672bd07 6710c387-8fde-439b-b204-af93c26a441e bb1a9b9c-d76d-4e9d-9c04-7c9b50313680 2fc3d6c4-64a8-4d0c-8ed5-8f9e56258ccb 4af7cc4d-e5ac-41b7-b02c-580749b2559e 333ab99d-dd98-4069-bbab-83db9544d975 3bff7044-4b0c-483d-8493-aeb739e2a5b2 8917359a-4b49-4768-9598-2f01d240b646 57130579-401c-4dd2-9bea-ea76e6b45738 6ab64fa3-a24b-4c21-a66f-982c12eb9bf8 53da208d-5f34-49be-be7d-e4f927651f8f a7c8beb8-1a6d-4c60-8796-d9843d42a1f0 f8c3abe9-2dbd-4c70-8f1e-f6eb9d05ca0a d0f511e6-906b-4d17-a061-1673f6c14bc6 9bb67171-ca67-452a-aa65-4a2516f86109 90df3c6f-c29c-4547-9051-a1c8a8d40d45 3276a235-9fde-4c44-9851-523ddcc4fa82 0ccfd108-1b3c-4d86-a169-e63656336310 17854500-6831-4b97-81e6-931ee7f72900 4365e379-847f-4bbb-a485-6911636b32a1 f2cd4fa0-b3c5-461e-93ce-a64883f888d7 910b3953-0551-4060-9591-0c29b4280623 fd7d4dc5-5afb-4ae3-a715-6463e3a435d8 39446017-0494-4e34-b686-8347367e8761 b5569aa0-8dad-48e0-ad85-cfec88bf7d5a dac16871-c479-4080-91d1-8e06a038abe7 906bb784-87d7-47ee-9c22-df9a1afd1636 5df5004a-cba5-40e6-ba4a-78f0eb39a847 3008b537-7f24-4f89-b407-6f2f38799d62 cdbd7932-9e7d-4c83-9983-cfb9a685f5d7 a4fd9743-8b49-4912-bb23-d1cf23afcf90 2ba53bd8-a278-4dd4-83b3-b7798cf6abdc fda66297-0085-47a6-93fb-6c9eafce89f1 bb27b65a-d2a3-4144-a268-d2032f66b001 967bbb24-cec6-4da9-82b1-23aed00c2e0a cec8c808-d581-4775-bde5-6d13d89fb3b8 c78944ac-c2e2-4774-90df-a76bded15fe5 c9f9d305-7b34-400f-b017-ef393a21c67d 33080a75-d7cf-4c42-9c1c-79bd9edd52c9 16783a16-fc0c-4761-936f-d8c6eaab3af0 b9647e55-ec00-4a47-a0a0-e6afe3a39b64 fe2d994c-0421-4b52-9b92-9c4a2e7def63 cee04627-e8db-4ddf-8496-b454bffe5386 406c4824-ce1b-4d06-a729-115d497dda65 1ba7e7a7-5e2d-43d4-a541-61ee542e6894 c20148e9-ccfe-46b3-9f2c-80215bcbfe53 82914803-3bda-40d3-9444-ab25d1a5fb39 0eaaeaf0-3b30-4f33-a0a6-e84a22598952 782ad96f-cacc-4df4-bc88-10a992b9f889 b8d9ddeb-6438-41b0-b78b-4de2f5720f49 2e9e9aea-c916-4203-9d49-4f312b6330f4 9d2178d4-b594-485e-a25d-a6a56e0dbb98 18b3df4e-dc24-4d85-8e0e-c86980a58f4e 492cdb10-5d68-4f11-9644-4027211efb70 2ad9e1ef-0d70-4948-9f8c-9b63f6cec945 c1f11d3b-4884-439d-9418-53c8b450c4a6 2b4d6e91-c104-4ba4-b63f-c63a4815629c 2a843894-0307-42e1-ad38-dbbd63943987 e79a4ff5-f8ee-4842-b714-a5001490ee14 ca27d6d9-5ff2-477f-a617-2ca103d2efda 801cd1cb-b075-40fb-a0aa-e9910ae45e8f 744a0d19-3664-4f77-b944-80c82a811788 da917658-69ea-48a6-860b-6a687ff118c3 215bf769-684a-4641-8bee-0e1119e52cde d7aa424e-50f4-428b-a3d5-f2cbad3dfadf cec68d86-53ac-4f3e-8bfd-2b9767fea41c 8df5ecae-0740-4d65-b1d1-82432d2354ad 376df08c-97e2-4f66-982f-171e0749bfb4 64535d0a-0d5c-4ebc-9d72-c89cf7ae9315 aada1ff3-1872-40d5-9daa-043da523b0ca fdaf8625-fcf0-4af6-af07-76467e057e94 2d3db3c9-3624-4f55-b0d7-891af6105fa7 6d725e94-7b19-444f-8db3-702b99acdf21 3ee976f3-7434-4e14-a6d9-5297f0a33e2a 366d4d93-c320-4bc2-8c91-74727d6b378d 87df3d85-1452-411f-adf3-15cf321082f4 a30dca1a-cd72-430a-95fc-d3ac90ea7622 f1f1eaa5-93b3-43df-a0a8-2846130f2d83 0d2f8946-4174-4830-a04e-0a5eb7bc8ac6 7795525b-2414-4220-aa4f-c5e9f4ae0d52 65692d7a-e098-4e4b-bb00-5b46dc107386 50573d55-5c91-4e13-9212-1b48852ae034 86589bfb-4d49-4c88-b9e4-ce1234a07fa0 4d5208c7-0500-44ea-be45-427413ccd048 d9602a71-c1dc-4a70-80d2-27a75337e2ee 4a0dc487-b564-484b-b0df-5199b389c2aa 2c1fd60f-a2fb-46d1-8ffe-30f1d1d12500 62a33123-6f37-4c63-97bc-de2da417c4a7 50c32cd1-cf74-4f01-a45e-39802b5348f4 33767e16-90fd-4030-b927-d63f2c8c7d95 56b50dfd-b3e5-44c1-9371-6f1f16b15bcf ee10cc53-1810-4170-90c9-2e5e0f962416 931a5da0-d126-4591-83a9-e5809010caf4 c9d2357e-5db1-4224-b795-f284c17d6347 066d6ff8-2f9d-445d-acb8-9a1dbe84335f 9480ee5d-be8e-40ae-a95a-923e4491c84e 818767e9-91a7-451a-9ebc-a3609451029a 9faf76eb-29dd-4bf9-a558-e8d989cc3f26 0f86dfea-a324-4cfd-8d4e-83882310a379 c212e13f-dd37-4e23-983c-a91b63515044 3f9a7d4a-be02-43c1-a63f-340005387a50 8f205a84-9af1-4f17-b459-98a4b46fc4c2 df9157e0-565c-4714-9b84-e1cab06e056d e050f7d3-5e26-4427-8455-3d0ecc8bbbd5 4dd552d9-a641-4307-bdf5-655aad696dac 2f4018d5-299b-4603-900a-c2325222009a 53d9ba30-44d2-4d09-a721-c39121eee836 80bc78e7-468a-48fd-91c2-688875e64382 8cacf8e7-6aa0-4817-bbc7-49a4f274a1bf beef8339-42b2-4f84-900a-bf2ede5c56b6 1f3980c3-ba0e-49f0-ab71-31ed08953b7b 44b8eb7b-eb66-4d75-9319-8499d937c5a9 c38d7f13-109d-4ac5-b126-541e4f4ccfac 1759c8dd-a4cf-4391-b3a2-313f71fcf3fd 24e28aa0-6d66-4e66-9d81-1e61bc52938f 65332ae7-2ba7-432f-bb25-64b7ca586cc4 4ba34524-1231-4c17-8010-8aa4d405d279 1f8fad5c-a083-42e0-b796-ecfbabd16889 b96adc82-848c-425c-824f-b67abda2eed0 e446fea2-47cb-4af0-896b-be08fa4055e9 332b6a91-27c8-4bc9-8a28-92fdb07e60c8 66a5e0f5-0918-4453-b596-28eb3b1b0255 71331c95-03f2-4874-8b41-c0054b429583 b8f06d4f-42c2-46bb-89a9-bfb9ae2bfa58 ea248791-ba21-4915-926c-7e78fc8e8023 302723b0-bb9f-4317-9496-78ae8910e984 b5329731-63c8-409f-bce8-f77a76d98d19 75c1da84-02ea-4b35-a8fd-5b8bf300e188 93b44ebf-f397-4f46-b0a1-1660d1739ded 3e00912c-f0e3-4e7f-ad2e-0996b8b61943 0799df5f-0420-4a45-8cb8-3215656b7fba 5e15d94e-982e-4662-a829-86b263dba69a d2cd700e-e631-4548-9339-92eb00b0f716 6057be5f-f621-4c15-a4ed-f53842cd8a71 7dee407c-7204-4306-985e-1ef141c9bbcb 071e1ac5-420f-49b7-85b5-7b6b8cf922a0 45d399a2-07a0-4c17-94df-bc49c8b0fd2b f2707c83-a9f2-4546-8fc7-7beb077e6598 be305363-dbac-49f0-a8ad-0f5af845f65f 53d9b4fe-f179-4074-a6ff-e1220c3f187f b9ff5373-1d34-454b-9cba-7a3331e833ad 59144b69-1772-41bf-bebf-ab673d8a78c0 7723306f-c158-4526-aeef-658511adf548 7cfa8c17-9422-4ab0-b8c1-3df072329eb4 2512a82d-b6b5-446e-aa9f-da2230e1be80 311eeb55-2f95-419a-82f4-1d1056bc1af5 3d84901d-ef9e-44d9-90b6-7c42b73c5546 e31b531f-8dfc-4115-9684-640142b6c5c7 f529390b-dbcc-4e30-91a8-b8f02c9bd2bc 7dc69bca-53ab-4bcd-8bdb-d769fd844e03 f050a080-bccd-411d-91b9-6ea297c36b6e e28a8095-37fd-4191-b0dd-2b67d2aed44d 99ab313c-9a52-437e-811e-9fd0a5b3af9c e34c6124-25ae-4daf-98dc-6569a6999228 cfb1bc65-ccc4-4040-b07c-19484232a1fb b6dc3ccd-2c35-4e31-a701-d7609068838f c0c3979a-62a2-4f7e-b0ed-b92095fb27cc c3225619-064b-4b62-85ea-0ecffb59d428 78ef43f6-0959-4ef0-bb23-1b837c1c5142 263f3074-2988-4587-a730-aef532b7d3fa e0c630af-2ffe-4e0b-a58e-df22e08177ee

## 3. Inputs and Contracts
Input: Profile metadata for check_running_chrome().
Output: Script execution status.

## 4. Execute
- Write check_running_chrome() in import-chrome-profile.sh.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "check_running_chrome()"` or `bash -c "check_running_chrome()"` depending on the environment. Expected output: success for ImporterProcessCheck(SH).

## 7. Done When
- [ ] Criterion 1: check_running_chrome() is implemented.
- [ ] Criterion 2: Linter passes for file scripts/import-chrome-profile.sh.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.

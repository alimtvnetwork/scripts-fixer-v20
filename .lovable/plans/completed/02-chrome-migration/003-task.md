---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/export-chrome-profile.ps1]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section3"
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
  tests: "unit test-3"
  ci_cd_guard: "linter-scripts/check-powershell.ps1"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 003 — Snapshot to Temp (PS1)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for SnapshottoTemp(PS1).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Copy SQLite and JSON files to env:TEMP/chrome-export-guid. 8e9f7410-f3a6-4ae2-a742-97c2f2befa7c 58e4d96a-37aa-4ee6-b731-fbddd1ca34d2 0fbe0b31-b16c-4170-bc92-48b76ec7bb10 6c9b3f2a-524f-4dfa-b1a3-42346cc85458 9aa15ac6-c8a6-4c00-8965-18188dbdaa36 69bc4846-0f0a-4c8a-bed8-1a500ff4b533 4a33abc3-58b5-459f-8e78-6ac4efe3ee9b b66d66fc-d79d-4ed6-8e61-3f6b92fd84e8 898d8f1f-c1dc-44d4-aee5-e82a59931f88 f93f6ae8-7463-4c12-876c-70f0b635d094 d7a8fee5-4294-404a-aa7f-303ce038ab4e 9ad4a84f-d7c7-4a4c-8c1f-1465d6ee92c1 f64e8863-3844-44be-b456-2aca7b6fd4d4 2ef8f920-046e-462a-8117-051d0f00c6f7 8b598661-6ca0-422c-9a41-570100581df1 16b528fc-7439-42c5-8ba9-da87303836d2 63e8d525-bfe2-4f88-a1b5-126f443caaa1 e0e8db36-26c2-470f-b364-d3bc61621fb5 a3ebbbc3-58c4-4f81-b346-90536776be0a 8e67c105-0dc0-4d4d-b184-2a61bdc2c3f3 7b1b2c04-dc78-46be-b84b-d9569991cb9a 766ba822-4d8b-489a-b1c0-090db0fe0a60 c70aa589-c12c-44de-993c-bcc6a5d9a8c7 c0d7543e-9a37-44d2-a22c-911908d1555d dd453b7e-98c9-4326-99fa-a3a3d1e04ebe 4394e9dd-62d6-457b-a319-1c855a2fe76c 885bbd6e-1b72-4083-8054-f5d35fa32897 e1b1fdc8-18ed-4007-8c7c-fb779b641ab1 d5248ba1-11a2-4607-a28f-cd75ac8207b9 08623882-f11f-4ce0-82d5-1a30f4e3d812 14c25a9a-9dd0-4e95-948e-9e2405eea532 3242adca-ff7f-442b-b059-ae3c925f58ac 5f746973-1340-4140-b447-3ef8e57beb80 d2af21c0-df40-4c3c-90b4-08692c273bc7 4919f31c-e43f-4786-a8c2-4a840ddd5c1c 6421d831-f1d1-432f-87bb-23da5b6663f0 c0444393-8b49-4a56-acfd-ee4748af3e9e 8160b67c-4f3d-4ec5-a072-7c992d2ac76a eff461a6-ecba-41c2-840b-60aa49e1bc66 f5b0bd25-52fb-44b2-b4ec-7c81e89781c5 437b3f8d-f1f2-4a73-bc05-b7121c299a65 3e95e456-e95e-4474-86b7-6343a1ef9341 46a461b7-e838-4aaf-8c29-4677246df169 50779270-92e1-4299-a157-40af64302864 9738c93a-8b85-4a8f-a4dc-07b6ce016f72 7b513445-ae46-4052-bcf0-783f8cb2810f 2b22411e-ce9d-4516-ba99-72fce66e24e5 5faa1dee-8b64-4b71-b72c-db4a5a91144a 79280e0c-726f-4ba8-a9d1-030da312f372 c9b20433-7b74-4313-a7d0-8ea86edc92e4 bd2cccab-0062-4146-b31d-9565c9cca3ca f44490a3-d57d-43bb-9da3-9ed1d4164df9 3d7b85e1-d027-4371-8691-2592bc967628 677d1003-fb75-4b84-9b29-27233979af4b 0e617a3c-211d-4179-af66-c16e515cbe17 f4b02494-962d-4400-8825-a64aa5dac9d9 98804fa8-2d92-492d-9ca8-eb7c198e4781 16206f33-0e98-435c-aded-3797e69dbadc b04460b6-c41b-4c9a-8e26-4839bae52297 988a59c5-183e-4130-b5a1-e36b2e28854b 90b62651-fce7-4ab4-913c-6a6371f284b2 a524dcb5-dfdb-45e3-8571-69a58ab1f8d0 380138f8-d80d-4d25-9ad6-84a5deda360a 8dbeb6ff-0d65-4980-ace6-174b4671deb1 51991867-94e6-4818-9b6c-c4165141995f 61544c7d-676f-483d-bf6f-fa26d85f7bb7 ebebdcf8-c779-4fbf-b0d7-b318d326b719 b6ac4bac-a5e5-415f-89f6-c461a5476701 ee12a05b-3953-4480-832a-ae3a3be72c09 44ddc7e1-8ba4-46dd-baf8-ca27ebe6a0c4 f45e80a3-dc4e-49c8-ba47-6355f534bf8c ee973048-cc7a-4b93-8115-ff4a4bac8dca aa9fbb5f-b92c-4b2b-8843-316f7fcb1a43 e1a09c70-4ba5-4640-9c5e-7f7099510190 ae5d2f44-5113-4ffd-a5d3-6eee3a63e6e2 ba9485d7-fe4b-489f-b19e-41175a7abb2c ef8ac2d3-7208-4e5e-a977-d60ea27ce01d 5d3b0eab-3791-4355-bc67-476dfe26c7e3 d2f638ef-8228-4ff0-9aa6-a230f55abced 5cf0e1ca-55e9-49fa-ab97-901b2ce137ce 26ff2571-efc7-4cc2-88b2-77eb77b2eb44 c5e199fc-3ceb-4927-a3b6-cbb2e1bdf896 bead250f-f97e-4472-8f02-889ea07b7727 d962c487-b1c6-4029-b58a-2d29c2eed655 7ef665e5-bdb3-48d5-9163-5df2e938b3a7 c782fc4a-b96a-463d-8d73-5d5b97668e21 74776f7b-e653-449a-8c92-824b707b5033 5f1aad3c-6820-4f9f-bbe4-e165c372cbac 954b2b39-1e71-40ea-aa35-a5d10ea391a0 3d7b1930-7428-4845-831d-509f39f0d272 2dad9d60-e263-42c7-9aac-624f62e29de5 6fd8803a-5588-4805-abcc-6b3da77f6b49 9feac778-48f1-4530-81d8-6cdd0c1e13c3 76ac5c2a-1ec6-411a-9840-d45647caf15c 111b9f30-9bef-4994-9066-8a49c6535b9e 07a421da-5939-40e6-b09d-99db12b56642 c46994b0-3a33-4d9b-9792-6a6734d41907 69c3ac37-e43c-491c-b1ef-d9a336ff2ef8 18d6198e-03d2-420f-a653-042199e8a7c0 94e86981-3f67-4074-b77c-099b46faa358 52e0fef4-2493-4ac6-bcb3-fb80bc8d680b 315baed0-0f5d-4154-919e-7bc379f6d964 b7434514-d416-4fa1-ae52-0518629b304e a2763aae-3aa2-43ca-8b2f-2396e9d4042f 7faf127e-fdda-4b4d-b52c-4947a00e3764 cbca82bc-f376-4b6d-a8f7-82f5b6b1bc06 499c6ef0-e51d-4487-b0bf-dabf2c37dd48 f18558c7-ed87-44ae-9387-6524eb39e7bd 1c3c4d5c-c356-48fe-9de1-fbcdea0e5af0 fdb0fe27-3f5d-4dbd-9a44-b722a80347c5 6b199656-052c-4783-9284-2c3671d4e817 e4cac00e-d368-4f92-9eee-61b23b2147be faa4dceb-344a-4ea6-a201-50da5c2f2b47 66fd091e-df31-4bf3-8e19-924d68f22794 032160a2-8783-4484-ac46-dd516d8d9c61 e9bb5eda-0d4f-4f87-ae1f-55f60a323466 67d62a3f-bceb-4e88-9645-3fdd26966d2e 4f393a69-55df-4efc-a9ff-a2905df60d4d 388fcd58-c4af-42c5-8b30-3e6c502c3d28 8efad9de-84d2-49f6-b35f-6f1139d3ecc3 a75e9cde-4ca9-4a80-98f9-2c0c4ccb3b58 b6f33d7f-5959-4b93-83d3-7b74ea21bf0a 4b445b6c-ee23-4e90-977f-5a754e340078 2c7df7a4-1d81-4685-b789-ca4449f29cc2 b03a9f47-32b5-4ee7-9a62-76aa5633cfbc 10fa5449-a784-44ad-8778-1bef1ef70651 2e4539c0-972c-474e-99d0-ddd9fc71a461 80e4ef26-786b-4039-91d7-a91f410ce9d1 1bd5a703-c8a7-4321-abc7-dcc0bc79c664 ea1368ad-bda7-4eb7-9f7f-9bf3c0c7749c 1dacd3d2-d775-4e0d-bcbf-e87fc7f4b433 3f2b625e-f27d-41f8-9a53-374077bb57b1 1e9ddf17-1a3e-4c75-9e5b-054a029f90ba 61a4bf18-0b4e-4b90-b326-ab694282bb09 0050e326-7a44-45c3-a37f-29ff1ac2c597 a9673a5c-ddee-42d7-aded-82eee8493842 c1c8067f-969f-4a4b-8a21-863f048bde88 cf1f82db-d0be-41a3-bc67-d86eff70beb3 1cbfb5e5-9541-471c-a2aa-89567838a786 e4069dbc-3e60-4203-95e0-f1c4950068d1 f6932ea5-d254-480e-b87e-22d12f5fd875 6ff6014f-c45c-4901-8dca-d71445091c91 4aa76cae-91de-42a7-945c-f23f921e6fde e5daeacf-e973-4ed9-983c-ebc76c2e4576 b66ceeac-a772-4e1c-957f-6d508e88d894 5468dc96-73f6-4da4-a4fb-7186438d1369 e3a316eb-f4c5-4abc-9e75-dbe73711fcd9 5b137da5-1cba-4365-9e88-aa65ad27a9c9 01b0322c-2076-4be8-8f1d-86268a01dac9 b7e32459-1c10-4be4-8abc-0c0ffbee529b b372da5f-4a1f-4ef2-8469-4303ee9c7826 e30516d6-38bd-4ddc-96b4-b18f25450478 d3d0c1c9-9aa4-4dd7-9ced-df5be3160210 fd45ab9e-522a-4384-9c18-17abf1ef5a9a a37ca313-3672-4679-b4f0-f7f00bdfa5d8 30d43fc4-6303-412f-afaf-4495f920d54c 970ca50c-8adb-4054-863b-dc6cd96ccda0 4173400c-cc57-4051-acee-3e4d7a20ee91 005eedcf-4e3c-44e5-bf54-b92ae2a90ff3 bdde69b8-72ed-40fd-844a-7767e62a23dd eebbd9fa-f554-4868-ae4a-b571d18999b9 b1cf899b-33e4-428c-af8f-05cd11d15e4a bf3259b3-238c-4756-bb5a-e6bfb499f084 1c2d2f7e-17c1-4a99-b679-b7d9dff49240 8a6b3c7d-2c26-4b3d-b080-9b44102b7b7e 56471336-4b22-4542-b3eb-75e1fd18658b 10b62a4e-3e6c-4234-b80a-2ee1acb6a5a7 894ddcb2-cf42-40bb-89e1-b6e705775bde 0622cbec-6a69-40b8-b4e2-5b1751e2264b 5aaaa825-b8a6-415b-9758-d12c75edc012 023713ae-7349-4c9a-9940-4ddc537da451 ecd0022d-cc6d-442b-98cd-b968dff34a75 5e84a38e-467e-477c-85b5-ea4a8888439c 448a86f4-3afd-4e4d-8be1-5232191ed5e0 0a90256b-ed80-43a8-8525-2935229d5dd2 b5979eec-7fbe-4fac-beca-ddf479e44808 1e0c3830-0902-4bf7-b1ad-d4002d7cfccd 64b4d193-dd17-4726-8f67-e92fcdecdc3b e38c9c5b-e146-4986-9679-ad2251e6bfec 5b6f3f77-a4cc-4a70-a5d5-2fece7b48487 cc8f81f0-7d5d-4b5f-9558-9a873bbbe8fd 6f444ea9-0b47-4b71-a607-9f114be4ee81 ef969c45-380d-45dc-97eb-d405e9c5a8cb 1b7862a3-24f1-4f31-97c0-c3056299c5ad 6026a849-e3a5-4afd-b282-19de252d2231 1b4ea227-c0f7-4ed2-a268-a80a7cbd35e0 c53ad9a2-da8c-4173-bcfb-74b434146f9b fd3fd99f-62ee-4ce1-8ea8-5b9367059f9e 3b3ddaf2-e242-43e9-aaba-e74b372ba2b6 bcb07838-3481-456c-a962-c9813943a70a 295a351f-f7b4-428f-bb0b-361e7e43c75c 2b89d42c-09ce-481d-9418-00d34ea535f6 26050092-2502-4fc5-acc2-e5539a363ef4 71c1ec84-6f0c-47a4-915c-7ed77d9fa0b0 d75536ff-839f-4694-9d14-21b1d3eb5388 a04b2a2b-c8bf-4820-80a9-0d14507bf773 68a2f26a-d386-4e49-a9e0-59aa9127b4ef 4be11d8b-3927-440a-850b-10c26a06b78a c1ae1120-ce80-4b97-a72a-bf3e35d0a6e8 f6b831de-e340-4834-a47b-4fb94b1ba640 b129bfc9-e007-4a85-a145-9d6591e981d1 08954f27-50cd-4713-bd94-c5d44f29a23b a99aa0cb-7be8-4f46-bea1-80e9a1e3eace ac13b427-233b-4364-abff-bf00b8c6774f 3e5a3244-5c3b-44a0-bfef-4e5eb795ccf1 f78dfcea-f048-4c07-9329-00ad9760fad5 9b871881-7484-497d-8de7-32f0fa83146c 800731e9-e752-4be1-8fe2-8ff88def61fb a7edf065-e3aa-4e9c-bdb1-90b805c94aee 0ff694c0-2285-4031-b017-e0bcfcf0a072 abb706ac-f53a-449b-8617-16b9c6f3f2f5 337496bb-28f3-4f0b-a95e-64d902679075 76fa720d-2049-46d0-b72c-b7ebc61cd432 362651bf-a794-4872-b0e6-2f9773f08e4e 3d076b41-3a0a-443f-b2a7-52418f7d938a d912b2a8-588f-4fea-a905-c7766cf903ac 18d1f51b-f17b-4c2b-8e38-f157efe00fcb 78fccaae-2eb4-443a-b624-80f41663b0f4 0c09315e-f784-4b44-938f-0b743c0448e2 c92f71df-85ea-4613-b2e5-685604b356e4 1fbf93c3-5f4b-4b35-aff2-ed127c9a4f6c 7fc5e4cb-b283-49b0-8617-bb345dcb0f7c b7794214-6983-4ba0-8cfa-dd4a2a41efc0 a2e1f0c8-1b4d-4e58-a64d-63fe27f5fc6a 793aa620-2e7d-4bb1-9c3f-402090e1ec91 2a20ca83-d346-4d51-84f0-afb78a4a7e6a 0ec44605-8078-43f8-93d9-49f7ee34feb9 83397807-7c17-4798-b59f-94c321d5a072 211153ff-69df-44fa-8364-542ce9ad159e 6332994e-e5c3-4d7b-acce-7fdd99ab5958 8c47135b-74be-45a6-aa19-fbda395288f4 0a48e710-4977-4027-831c-537de57b16a7 5f1a441a-5592-4620-a708-304d59c6e5c0 ba0e7d27-a361-4381-9d62-a421d9c9a763 20854bd8-caf0-4cdf-a5bc-e5bdc7fd9d09 fddaace9-cdf5-474d-8394-cfd577d2ecfb f4f900b3-59f2-4355-8ff1-85bf8e509315 4e7432db-dbb6-49c4-b9ea-7557631a62b5 6b61dcb4-ff0f-41a6-9e11-f32f85660e1a 4ac49c7a-13ec-4bd9-842f-2d4873f60329 2a597a72-ac76-4bcb-b199-ab20ac1c6733 6f172ca3-1613-45f9-b6a2-f2c4f27fba38 5ac06244-6271-4a61-a677-9c84f1bb08ee 14d7f9e6-0162-41d2-bd22-cc2a6f8e14d6 218bdf39-35ee-4f57-b9e8-478924f1295e bac8c5bc-51c4-4903-8949-5192155288f6 c869452a-6d1d-489e-9438-858b3b748a15 72261c1f-30aa-498c-b0f4-af44feaf37f4 4766be40-881e-484e-a8cb-5dfebf345c74 783dd2a4-2046-4265-a5da-8b2df969e36a

## 3. Inputs and Contracts
Input: Profile metadata for Copy-ProfileDataToTemp.
Output: Script execution status.

## 4. Execute
- Write Copy-ProfileDataToTemp in export-chrome-profile.ps1.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "Copy-ProfileDataToTemp"` or `bash -c "Copy-ProfileDataToTemp"` depending on the environment. Expected output: success for SnapshottoTemp(PS1).

## 7. Done When
- [ ] Criterion 1: Copy-ProfileDataToTemp is implemented.
- [ ] Criterion 2: Linter passes for file scripts/export-chrome-profile.ps1.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.

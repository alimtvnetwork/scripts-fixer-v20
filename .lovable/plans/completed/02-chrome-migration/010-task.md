---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/export-chrome-profile.ps1]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section10"
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
  tests: "unit test-10"
  ci_cd_guard: "linter-scripts/check-powershell.ps1"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 010 — History Export (PS1)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for HistoryExport(PS1).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Query urls table for url, title, visit_count, typed_count, last_visit_time. 63e22b6b-4b03-4ea9-b54f-693dcc66041b 21715304-46d2-4eed-b1e3-e528dfb1cbdf 6d915b14-fa8b-4e08-bdf4-5e84a5fd5ca2 2837690f-0ad1-42d2-ba5d-8bc0d5746397 06f9045c-11c2-4dd8-afdb-2a249bd49ffd 9abd1eda-ad47-42a8-acd0-b9af7dea7948 7f86a680-e851-472e-88dd-214d362696d3 43d30f9e-a65a-4b2f-8bc6-b71ed4ea4827 03ba32bb-344a-4739-9227-743cd1232183 0893b8fb-97da-4fe7-ac29-96a45f7c7c9f fe72e58d-1b7a-44b8-ac24-4a7b9118458c 2594d6f2-bd87-4457-a267-2325e8c20ea2 92502b25-8681-4a6a-b604-dd1260710959 90971e86-d4cd-426e-bf0a-8cd2592f88e1 64f647d8-5b7f-4fcc-8ce4-5b3635cadfb5 8001c957-3f77-4adf-89eb-d9e9dedde15c 518dccb4-e49e-4b2b-a7ab-e1869d4a48b3 dd897830-5abb-4322-8e3d-a2fe117f5ccb cb3a4d56-c781-44c7-ac40-5ec8bf2a4b36 07885d64-83fe-45dc-b418-9e67be90c790 6fe7a31d-e35b-4ea3-8fa0-bcef686e2f0c 42732cc9-142b-4e86-bc51-15f598b06994 4dec9b17-6809-4efc-857a-e25d320c645f 25046ac5-0221-4da1-b2a0-24c868661867 ffc74072-6169-402d-9046-fdadee7aa334 1461fff0-eefd-4dcb-8cf8-dfe0791c7ef0 a4792536-b9cc-4882-ad6e-ce8f9a75af94 e37b2a69-705b-4e1f-8017-99c056eadede 10473d12-6460-4e03-9e5c-d51583fbcd6e cdb12dd5-cc77-4af7-b375-873f73bc9592 8a3fa8ea-b7b7-47a4-9f03-ffc98e42de9f 54378472-50df-4b12-9c0f-a74398bb599b 38da6fbb-c0a9-4d6e-8777-6b191fda749b 76f9445b-2364-410c-8f78-dd8b287af25a 5a55ea39-d0e5-42d4-ac61-0f8f00024c13 2daaaf7d-0f39-416e-87b3-d7ea2c0f88c8 497a38b8-7cdd-4d60-b42b-942e33e4bbe3 b94b5ca7-cb8c-4804-9755-1e7d3339b117 786d7045-1516-433b-94f4-f8917e6d1486 19f16093-a9db-4f2f-b80d-363da0829014 0c6ee594-22e0-4cb9-96e8-bee151e88f79 106fac1f-4c02-445d-9fab-320e37d9a3f9 e29c5587-065d-4929-a673-36a58758e5f3 c0c637fa-8057-4cf1-885e-1be1160529f4 68440050-bba7-49d8-83b9-2e6cdcb3570d 3adaa892-24a3-4275-979a-2d4d17f48fb9 ff1b32b7-53e5-4d3e-a2d8-7348d5f915fc 2cc62af0-e833-4257-a96b-7518d4d2b0a3 356d3725-f1a1-449d-8538-3dae1e0c40cc 3d473ca9-6a88-4262-ba3f-19a2ea4fd58c 0956f449-16b8-474b-bae9-03089109e9ab a3e2b037-f42b-44df-958e-d4e36b1a33f6 56396aeb-b8fc-4892-841a-01590682feb0 883fb07b-6414-4200-9dfa-84cf30f9c8a2 93534420-8190-4102-bcda-a065879da6b5 ef9b126f-7e38-4f6b-8a99-3bd37b6c78e8 0a14b6cf-3a36-4fe4-a8b4-20a738eb36f7 1776f554-95ec-4a89-a4ae-77c3543b6957 31727099-574e-4cb5-a419-0cd2c48a6133 53c3f513-a8b4-443a-b7aa-f9ccf38a052e 85a8c67a-c7c4-40e8-ab8e-082fb5464e94 79546966-3bae-4e3d-8c7d-68ec3fa4e9e8 91db5a4c-c80e-487b-b92e-61299236f184 f8d3795a-3cda-450d-b937-255d30ebe7f5 f3b746e6-54c3-421f-ab47-102bbca810bf 13216ad8-949a-4c16-8d3d-45f2e4a54ea2 55ef1d9d-09d3-44ba-8001-2a6c5775062a 9172b68b-b377-4b70-beba-533f92d7d8d7 dbc166e6-95c4-4c8b-a313-88b4101eb2fa ee185be8-90b9-4446-9c26-15f8ce18a82a e952ba4d-2dd8-4442-bd04-32c9730b36eb 282a9488-22d2-4165-a236-b5e3c18cd478 28935ef7-bb0c-47bb-ab88-21401f7e4353 1b301072-6502-4b3c-b04e-59aa5a744003 c337ee3c-1a02-4f80-b875-6ef996a7182d 71526ec4-ef92-46af-a856-44814fcc3c2b af58b13e-ca25-4d40-ad48-7e2474d5584e 1915b586-fef0-487d-9b0b-e8f199bfd847 cb261368-bf8e-4b46-8218-b488ff1c426b dde81a97-6011-44b3-9da6-24f987d4bf62 cd7a2c9c-f65c-4d43-8d4c-b8a8678d8101 045837c9-1806-4b95-aeba-4fed3b07a2cf 82b2fa8e-6ba4-441b-8cf3-0d25b8ce2aeb 9cf48a3f-550f-4377-8087-9a332aeeb417 712ca79a-9b2b-4b53-a12e-6a5fa5238915 1f03fc36-b500-4c74-99cb-6d0f0e0da6b7 5f0d90b1-8681-46f4-8ca7-8791788f5116 3a029738-96d0-493f-a70b-edd1ac480a7d 7c462269-0f84-459d-b5b7-1961c7413a75 082ccd2e-7e05-4bf7-aa91-91ca30ee5f06 89f9d2b6-f0aa-456d-b316-6a22565d6ac6 20f5fb85-15f5-421a-8855-b8fb1b7ecc20 243cb10c-9ed9-427f-85d1-03752cffb0ea 77f2c376-6b20-4a78-9fe2-1ab61084f2ab c9b66b24-e045-4969-b757-a01783e76f5c 40dd6971-f75e-444d-9d46-ce17e630f819 ebb066c2-abef-4a0c-b444-105d8d33b9fb a2f65f3f-c8e2-4e63-94ba-5356a6d5508c f8998916-77ca-4faa-89fd-7314e3bc2294 9129139f-1555-4992-b6a5-bffddce8b8cc 88c4d893-7d28-4d9a-b5c5-057d69e8ae15 6a143f85-cc3d-4558-9404-ab86761e9b07 c78ce9bb-35f3-4bfa-bcf6-35f315737274 e382aef9-b348-44e2-96e2-e3ecad4f5eeb d0bac55b-f384-46da-ab91-d5230f687094 f98230d0-f55e-4678-9a0a-04f8724517c1 0576a670-0887-493a-8b4d-f87b0096a075 b7137e15-115f-465b-a581-e2079b3dc189 cbd98d68-41c6-4a8d-9993-385db48cff13 9141fea4-6075-4414-a9e8-fb9911ef2d5f febbd358-e457-4a11-99e5-7dcdfc4d8a1f d7edf2a0-3f13-4699-b308-e4c7d795bbc4 3ba897d3-99e3-40bb-8769-8fe4b1a12197 d0ff2d8d-b63d-4be2-8db7-7db771655ea2 a4d7f77c-e339-4265-a719-df70b3aa6335 ac570f70-1a57-45d8-93d2-6fcb863ed94d e9ebe1aa-0327-4b49-ad64-0c426aafe97e db5e8ded-f09c-4c1f-a07e-82800a93a21e d99171b3-3ddf-4bde-a586-7c07d4bd53d0 9eaea887-183c-4c25-8ccc-d049a812eb5f abd7c6c8-20eb-4a36-a956-f63d768f6de0 aa836f5e-ce66-4ec1-a0bd-43db6d002ade 6873e175-539b-45f3-b310-f9565d897075 a041c494-9787-492c-ba13-d2a78c6fae2f 7915366a-18f5-4c5a-9a19-6f927cc32ad9 8a967ec9-c29d-4ca0-9ff3-512c7749698a c5211454-33a3-4004-a144-804120c37ac7 08a522aa-2bc6-426d-874a-3f21de755cda 118c0e56-ddc3-4ee5-a30b-1b88504ad8e2 4e3dbcb1-330f-4f2b-9599-213fe5ea73ae 509c2550-d806-4e9f-ab88-4db0e34b99f2 4aafe33f-b321-4990-9eb0-dd95ce26bce9 3688b924-baa1-42df-a3c9-f2e5013e15d5 b30f5693-c5b7-4390-86c3-8d5a04872ae8 887fa5d5-2b3d-4085-9fc6-01c9a5d06bed dcfa3d33-6c8a-4910-858f-cac108c66dac 3b98b970-3e4b-4034-9cde-8af5d9e0cd45 74e827c3-67b1-449f-a86b-4417410cd673 586ae6f2-da82-4280-8b97-a1857e44067d 059d6e0a-f0fe-4aaf-9ecf-fce2c8995263 65985d73-3e8e-4c57-a28f-8928b801ed15 07b46ee2-4c2f-4ded-98de-1831609d3330 c2d0c61b-c53a-44ed-9547-be9454acd13c 6d5f0b8a-0c51-46d0-872b-80745e56f6c1 9201a7f0-4bbb-4428-bf44-7c7e4873ae15 23e4c0ca-6183-4ce6-9c8f-a5182c9b56bb 57994669-0c21-40c6-b4bd-b105e0a3582b c2910242-d7e9-4340-bb14-c9baf462b33b b59ab4d9-f9c2-4322-bc4f-9da680292a99 7b17e1d9-e235-4155-8de0-402b183f9b28 d35b9e5b-a926-450c-918b-7befb4f3640f 66068401-645c-4df4-90d2-2133a24a515b 69c47611-0240-4378-97ee-ba906c36bb93 0da8d483-16c1-42f2-b80c-dfe0e7a263eb 0dd706ba-6494-4c3e-bc3a-72448ced33b7 dfc99f83-7f1f-4757-983c-6ea38f37f712 55db4385-c619-4e02-8112-9b67a3f67d99 06633a21-ca27-4c7f-b1ef-ab1e0d7859b4 7f7f9292-d56c-47a3-a4e7-097579077959 0267f0ec-318c-4d4d-ad7f-f2bab9c13d5a 0719fd42-4792-4c2b-b23c-22844341aeb3 c296d03b-d8b5-4070-b038-d2abeed4d6fd 9fed4e0e-7a18-40a6-b081-d23d9d1351a3 a2101b1b-1ac2-4070-ac98-0a6def99bd60 6206344d-e9c0-44d4-8dbd-3f4949f1012d aee41ac5-e428-4194-9f76-2abb05d29296 9c527ecf-d7e9-4797-882c-176cd6e10519 b48245a3-44b0-436c-813b-523cf57ec14a 7affdb03-310f-4a89-a099-66bbf237d634 5f5cbf62-1883-4364-9c34-d2a897ccb40a 93e94d16-4301-410c-90b7-6c006c77f441 05d86a7c-e062-4c9b-957b-81288d0c5625 f6819c96-2f99-41c8-8697-f8379e6786cb e68a3792-065d-419d-b107-ae06488bd823 e861428c-bb96-45de-b85a-0c7d20861aea 28725569-97db-4fc8-91e9-63ccf2b2c9f7 2c92e381-075e-486b-9d5a-9d4292c8d4f0 725229ac-c792-4792-963e-964a255c2abc 4b574462-1945-4871-b5d5-7dc1cb5255f6 6260c309-19af-4df1-a6a9-722e6fe72ca6 45f0d77f-4be9-4b3d-8b67-2299419079cb 671da93c-1c86-4bf3-ad71-b63a4de669d3 1db41ffa-bf33-4128-8777-96a83be0a390 4d78479d-83dd-462a-a7da-121e4405d435 232d7dd4-1343-4fc3-8b36-f2538aabfa10 e1fe7c4f-51a4-4cc7-ab07-687d91d26a4f 094fb48a-22ff-4170-a856-96090bccf989 75f784be-e493-4680-9504-b3cd6953370a 29104816-d926-45d1-bcbd-01fef1f55903 7e5ae268-6203-4d86-814c-31317ffd5265 34b14df1-6562-42dc-ba2d-544d09635e46 50626b48-e7fb-47f1-85a6-778cf6dcbf27 2e6a629c-df63-4cc2-adf1-dda7b3b88b28 f0b462c1-e3e6-408a-956c-0c2b63721932 eef68228-6176-4485-a0e9-111e110fe4e8 a886a0b7-7c10-4aa7-9379-3a2a1fb8ce45 018f2c44-6630-463e-aaf8-b9ac748d820e 1d272d7d-065b-42bc-b7be-03580b5ca52a 633c011f-3f85-4f77-9af0-23dcf7dea056 c6ed0ec0-3df0-4075-8e55-b7fb7cb12b1e 019b0988-2d0b-41be-b5d3-5c2b643dcd8c e57f8ede-0df5-4bfb-bb81-aa702582ab76 8305a649-165d-454f-bfee-facaa4b5f47b 7569a2d9-5de8-4972-a3ef-68628326701f dd82d500-a3d4-4f71-b001-8aac8c976aed 274dce03-6956-4f46-a1b8-567126c3e4e2 7b71102f-5946-488d-84b5-686b8b03077f 6d5918ef-fc41-4c35-811a-f3d2832ce76b 37660f72-bb75-456e-a9ed-189a5b0dba54 2a1ecc9e-669f-4df1-b54c-5d70ef631bba ac2ebc47-30cd-4556-a791-3ba6a13513a9 3f0b9931-b5b7-4c4c-8472-3e7d4bd4967f 0fcf315d-cace-45de-94b1-82fd37e6a037 5074967a-012b-4bdd-9ee9-3b8cd458c158 59d73ecd-2948-45a7-8105-fdcb2d888418 496aba66-7556-4bef-8186-692f3a69d2da 5e074032-73ea-4a75-9621-5e6ba0917bd0 6235f019-4724-47f8-87f3-96ac4da07068 8f822f18-262d-4fdf-9018-63a09e7eb4e9 7535cacf-b112-42ed-a5ae-20a44bcf5d7d 169ccca8-c212-4ce2-8fdf-d0d51bb19f07 9e86e662-e00c-4559-b46f-2ed143d28557 254c5287-795d-406d-b678-e0545ffe71d0 cf8c26ba-fc15-4d8d-9dd7-0cea2c30dcb2 e67fafd6-e676-4336-9be4-2f5d3ae7e55a 95eb90d6-8baf-4f58-98ed-b70dda86ac24 7c3aed88-7d0d-45c8-a120-b6466f77baca 9eb97b2c-1448-4023-b2ea-67192b84b88c dae34516-3a26-4dae-9bf8-8b8557319d4f 870dda8e-4428-4763-9fe3-09587ddf9d95 ed318beb-1e6d-4e13-a2e0-3afa1cfa7035 1fd3540b-ee39-4ba9-8742-2eee91e34ce6 ff21d080-3007-4040-8973-ef4283baa0f3 68d93412-3a73-4f1a-9d79-1e98b1f4dd3a ad747b95-3324-418b-a5f9-1cc82b5f0cff 491b916a-d912-46c1-8bf7-9a9322b425e2 84e6c1d9-8db3-4b9c-8763-de8c576fc729 a89a2b7e-f464-45db-a01c-1646776d3321 0fd070b8-7531-4daa-9829-be48c5e52dc8 0f491f59-5377-4a15-b34f-3510505f095a aa632496-a1c0-4025-97e6-c85e55cbc15f d9507f6d-300f-476b-903f-e600b0ef054d 728a93b5-0acb-444a-a43c-d32c56164d0a f7e6e9c5-89b8-41ad-ba9a-6723fc261f00 484dc2b7-e53f-4223-a2eb-9017f0b2e9d1 619167d7-13ff-4d74-8354-72b23b45da62 8b78a9b3-6614-4685-bce3-5390f237e1ff 8ae69011-2c1c-49f8-8a2f-35d235c217ec 4a6e3f4a-7fff-4ff4-89f3-f423a24a2de5 b83d8b3e-d43b-4e68-aa46-001c7fe4178f

## 3. Inputs and Contracts
Input: Profile metadata for Export-History.
Output: Script execution status.

## 4. Execute
- Write Export-History in export-chrome-profile.ps1.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "Export-History"` or `bash -c "Export-History"` depending on the environment. Expected output: success for HistoryExport(PS1).

## 7. Done When
- [ ] Criterion 1: Export-History is implemented.
- [ ] Criterion 2: Linter passes for file scripts/export-chrome-profile.ps1.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.

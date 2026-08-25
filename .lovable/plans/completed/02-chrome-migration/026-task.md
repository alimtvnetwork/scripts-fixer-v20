---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/import-chrome-profile.sh]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section26"
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
  tests: "unit test-26"
  ci_cd_guard: "linter-scripts/check-bash.sh"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 026 — History Import (SH)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for HistoryImport(SH).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Convert ISO dates to WebKit us. INSERT OR IGNORE into urls. bab1398b-26cd-4792-978f-154c2f79df74 cba92f4f-9c1f-4088-99f6-2169c69febbe ecb83697-fcda-4887-9baf-8b1954043da4 bba1718c-1c9e-4af1-b1d5-100952edb767 55990752-43b9-45dd-aa20-f345f548a5bf ed8e042b-b8e6-4fab-8c84-f0354328d041 993c6ff1-c385-4e80-a200-ba0f91d04c96 8331740b-e6c3-46a4-b688-d27c18272108 3f69fa25-285c-40df-befa-6f01a1f0f22f a5602bf3-1bfc-4674-b038-aac283e27731 d94e5db8-b416-47f7-8a8d-f4375994a4e3 7ddadb90-3fd2-41bd-aa02-324b269994ed 0751724b-b493-4397-9f5c-2f2231f6dc7a 88ea920b-91ce-4e9b-8d56-75ec00fe5bb9 1e3442bd-d540-4734-8edb-1c62d48dc56c 7edc8fc7-bd70-4d25-a165-cf39fb097983 e0b2c448-634d-4d66-a2a5-44ba37960021 b03a90d2-0080-43ed-8367-f2fba3050bd3 b41e8e70-823e-4fc9-83d6-cb76e7b560a5 bd07be2d-a2ec-48a1-a328-8392b8d22708 102545c8-d6ed-4154-a6bd-820d7e5310ef 7c51dd8d-296c-4413-b5ba-40da5d64d6fb c1ed1498-56ad-487f-80ee-a68dc31b117d ef848006-4a4d-468e-8f31-41ec185e7aae c44b6238-f216-47a4-96f2-f6d495d930c3 4f4a45f4-1671-4f70-a768-883f80eb5503 97d0bc42-e3d6-42a1-8b81-69d3c6dd76b2 8c3b5510-b0e7-427e-bacd-06239140dc61 32dae949-afaa-48a2-b11f-e1ecd7f11ac8 28575fc1-8fa8-42e8-901c-ac3363474255 4fccb32d-6f84-4d09-a694-05e071b09f72 318c3325-2c17-4be1-a0fd-1f85985136e4 6a9a6c2c-bd9f-49bf-bfd1-1e6635802780 89687071-3e2f-440e-b6c6-773c0dc8c28c 0fb17d8a-e1e2-45f8-9147-86c278a0811e ccf941fe-2d44-4573-9b1c-c37c92ba36fa ac6238a0-030f-453a-b7d0-626d7beaa351 0dc8b6b9-2e6f-4910-8079-3be14af8016e b0f4707e-216f-4a35-bef2-2ac37eb12670 a7e98e88-5ee9-4e4c-a45e-36b56ea370a3 5da8ee72-0d6d-4c56-95c6-b13fd668c0c7 f588c2a5-6190-4697-a9c5-1a547c143a74 c18726da-dd64-4375-9ad8-82b0d64db1aa cc6ef50b-7793-4fb0-aa65-0bb2d806f2cb bfd45cb4-4179-4fbf-a8d4-7483f9996cf3 f4a94eac-bc3f-48ac-8164-d5519d26b5c0 6e96c1dc-0046-403c-b7a6-4c90982e3f58 6f57a751-a986-4387-b615-7dc2b9423516 a6d2cd91-4c1a-492d-bf0c-347971e29653 3834d3e3-3870-4737-9d21-17d59e256d75 b39e3fd6-dfae-4646-bf93-7192d45d8c07 f8245ac8-94d6-4b2c-9f5e-b8f5a8d4ee77 0de09dda-f521-4f7e-aa82-c28885cbb52e 47a98edc-f153-4b8d-8228-af41fc4792b0 47cedb0e-afbb-4b50-b9ae-dd2b7732a7d3 b3a75809-0fd4-4a38-80bb-7009c3a5073d ee58326e-0f15-496a-8bd9-def4cc4df96c a0f7c4fc-db8c-4114-875c-073fae220670 58b53ea7-8126-45e5-a84d-38e5fa78ba89 ef048598-44d2-4214-b200-63cd824b390b af764a77-9b2a-4cde-8b3c-e26ac0384ed0 8194fdea-7386-497d-80b9-7d45796132a3 55dbb11c-0795-4cee-8c4b-ef20aea085ec e6c6d194-85a5-43da-b528-8eff623fcaac 03d83bdf-1fda-4ba1-a8b2-f06b257b0111 311f13d9-7e1a-489a-961b-13352c7256cd 96927634-f493-4258-823d-e3165bfab0cd 1e5f79ed-3e09-4e92-a38f-390ceecc517a 3b0ef473-cb71-45f1-a3c2-1ee4aa9ae3f3 45bbbba4-a5e6-4770-b5de-3b4aaa27d611 b4385b3d-0610-4976-a620-34ad43c1ca1b b1ff4090-533d-48d9-8093-0aed551a2247 29563989-bd6c-4902-a13b-21493f9cfe5c 7f66912f-7fe1-4852-b50b-9fe97649ba0f b092e914-1752-4e4a-8c71-b703eb5a3e7f 9d47a867-ecfe-48d2-a0ce-d057b16d5c41 6fea8878-df28-4355-b0dd-7460816c094b dda1bbb4-889a-41fc-816d-980e60e6e845 d5ab9f86-f568-4d9a-bf37-9acb6b646779 4a36a9da-1f1b-4511-b8db-4145d7d848db 5568f0f3-ceae-44ca-9188-893bd92316c3 af9e3691-75d4-4b9e-a86f-207b5a9b38d3 903018c0-a28a-4b94-8afe-2f2b9102f1a9 40180227-6a52-4364-9207-ba52bd281241 40b0855f-2823-40d2-99c0-b79f42929ca9 a3fafb46-c527-4f51-8ed2-f1e284d7e897 602b59c4-51c2-4561-a3e2-ffed3631c1d2 13fdbe37-29d0-4900-8857-bdceae0b6fa2 27a174f2-7712-4eb4-8a7d-ab8e57ffc2e6 2042f95e-7939-4368-bfd5-39494184cb37 758003d2-4272-4358-9917-4852f17374c5 67befe5f-1d3b-4c8b-a84f-534a3c4afc63 8ce26fa8-13eb-4d96-a64d-f1c2235a1b8c 3b9d83c8-d997-4e9c-b7bb-a126272286d8 070834bc-2e33-4304-b0bb-4f131e0b0014 52a11746-080d-4246-9e79-59709d7a9003 5c65bdc1-f502-48d0-87a4-4e56f9d7dd25 ae503b9a-a65c-40c4-a0fd-567f1fd92c2c 64744e45-059f-4ff7-940c-95ad116843a8 652af163-6fdf-4569-a185-1a0ed3ada989 9f349bb0-50db-4ef2-8a86-44791face59a 8d671b78-9ccd-491e-933d-fdad7495d1e2 ab9b316f-f7bf-4e98-93bd-110ed3bf61fc aa27d699-6bd2-4543-badd-b4cce1db1605 26dd07f0-77ee-4211-bc22-fd66335bf708 a3004e70-823e-496b-98a3-bb1f1b26f9b9 010282bf-45d8-4859-b592-b63e27a3fcad bd4adb02-ed1e-44c0-9b77-60086102e42c 3f1154d5-af5d-430b-8d92-1d80ca31255b 12a31292-7558-454c-991c-5868eaa52f34 0b824e61-d8ba-4119-8576-9798c07e453a 379498b9-7472-4371-84fa-406c39f6643b 94ade25c-7b17-4a62-8662-02bc47135cb1 66f93112-8a2c-4d09-b32c-337ccddd62eb 47a4d032-445c-42e9-a6e1-879c548a0239 59d71c93-399b-40be-bbcb-a6ccfa036ef9 6310f784-2c4e-476b-9651-bfd067b39f70 8d6eb7f2-7c38-475c-8301-5e6436040c39 b704480f-80f5-4aab-b176-3d4df2749b6a b2be0680-ee57-4122-bfde-ee1266b7e45e 24990774-4c35-4c3a-a5fb-04b0071d10ba de3a06fb-0a46-4357-b84a-27b37f0aedb1 edac10f3-2558-4587-bd3c-e5635ac6befd 78e72d43-f968-4b8a-8273-2bc857d47cad 40986bd3-cd34-4893-8480-883d08b1ba21 10221d5f-9f4d-4156-8e57-aaea354c70b3 9a8d0c13-f21d-4a92-bf1d-e35917f9da16 05e860cb-bce8-4f5a-845d-911158f57948 e4e1e969-3b5d-4722-9064-642b6bcac46b 3b30b1cc-8afe-4152-8b37-46a5b063bf18 5e0788c0-0341-49b6-a3b4-85448fbef456 b1de3051-0f9f-4599-a8b3-986c604b04ff b6bcf5fa-0349-46fc-ab4b-13e39a32b4ef 50067165-41fa-415f-9ad3-dd4aa6354c71 7ff20b87-a22b-4136-bd3a-a53723b5c2ad 4c9d6408-074e-4f8b-bf3b-402dc90da46f 128a0f1a-2b46-409e-bd4e-2939b050b28b 0f58d356-b71d-41ec-85fa-54cb1fa10535 97ab30df-7de1-4501-9064-0cba116a9a19 d5d5605b-00b4-4510-a37c-73eec6e97d70 8aa35727-8302-4c76-ab0e-3484a0dad5d0 131231e9-1fbe-49a0-9655-e5dddc5e5a1a 6ec2997f-ecdc-4770-9a14-1fc12a730b34 ddb9d49f-7549-4195-b7ea-a1d4fa99809a 2763e088-f8c8-4589-930f-d4a336b693ac afcc6521-bb69-47fa-be9b-e8d49273f83c 8f74be56-487d-4328-9c7d-f12bb877cdfc a4a4fce1-eb9d-4de0-9aa1-d30bfdcdc74c 863f1001-94ed-4741-80fc-9d6e98ebf769 f913e95b-e553-4ac0-9566-a9e1307324b9 31a2a3d5-4ea8-41d5-b1ef-3647c3f7e45f a0dc619a-5d41-49a6-bd07-d4764e5e6d40 1f6286ad-f202-4602-923d-d1f3032e5eeb 40c29a25-d455-425f-bd5f-966cdc60eeb5 9c15b6f6-91a5-491a-8e0b-b2dab0905284 e81e19a4-f83f-4697-b9df-0301e3d072fe c86f43bd-6939-42c8-84ed-5bd78f1cd88e 317aeaaf-23cc-4ed8-b1b7-8f850e5618ab 9935b736-282b-4e61-983b-ecbba55c253f c8f6ac01-66a9-44a1-b6c9-05665a3dd6a4 9ad2f845-0ccc-46c1-86f5-ff991e5b82e5 c157c39e-80ec-4082-a6c2-5170b03c66ac 80d17b89-46e6-424b-a559-9b6261c505a1 30274d7a-7b0e-41fe-be09-8f63bac96a76 2b9029af-f5d5-4176-b132-afb650f4b14e 486ef9fd-5f51-4cd9-950f-645396f625aa 84e2f61e-ea12-484a-964f-79638ebac4e8 631bb641-a45a-4be4-b5e3-45c486bc4126 ee8c97c0-25b3-4be9-9d9e-24517be7b8d2 572970ee-e7e9-47a7-84ca-a53e56d23705 b0a7c6d7-0bdb-4f5c-b821-f4b0dece015b 262035b8-66cb-4209-84bb-10bdaa957655 7aa12239-8b4e-4fcd-a699-a8cf6b82b3e6 09369786-d35c-497c-aaf5-981b85dfbb1e be46f6cb-86ab-4dae-b0f4-4af2a8241988 49e7749a-64cd-47b1-be1a-8999d5f8d633 67248f84-a908-41d5-9bd0-4e68ea5bc055 6a417f19-63f3-47bd-9e3b-20058e6fad92 06049fe6-6ca2-4985-8e1b-6fc02a53f004 9f5f9f71-29d9-4566-a726-ae28c6deeb78 7d5ad0f1-5adf-40e3-b88f-2cc718449d23 57745646-afc0-4305-8af2-67e4e206a209 a2a06bdf-a6c6-42a7-9834-e06d59637cce 9d59c71b-8698-468b-a0cf-71199a938ef6 193cb56b-2f7c-44c4-96d0-9171d9a3e07a af6cd860-55c2-4a5a-ab92-fc8200cb19be 0a762f59-5a9d-410b-b39e-a42cd664a293 63a9fdca-68ca-4738-bf92-30bb79dbc096 c29460d6-bfe6-4e63-81c8-fa673822b551 31f22e25-d163-40b4-907b-5ba474b60cd6 3df46d41-bace-4a7c-a787-080e825db629 7edcbd40-69d3-4bf6-a22a-e6a048fa30b0 769f79cf-4b72-4c93-b140-c03409ee574e a502ba3b-0d4a-4ab6-b628-8fb88f451480 0c6bbf9b-2394-4418-abe5-4dd89332c1e2 4a334f4a-d7f2-4d1f-b9b2-585a70dcbaee 7d2d3201-a92c-456e-b9b0-e19dbbe71c09 52c43afd-3756-4593-8154-32bd7be2c29e cbb37318-fe9d-475a-8217-0c0c804a13ca aad8f9c3-a260-4e82-b75c-759749d7c0ac 49c44268-12b5-4e10-afce-df8dbaa33cd3 66e7ec21-e00d-43da-b032-4db54528b920 442148fe-f15a-4728-86e3-ec589086ebaf f3541e14-9f37-41e9-9d4f-c7059a2b720a e3b53d2a-68fa-4b55-a326-487f445faaf1 983042e7-c576-429e-a209-a4794c16bf8f 165b998b-af49-4a5e-8d45-64fcd653f1ea e50315b8-672a-4771-82be-2a88e92fcb3f ce23fba7-a9fa-4b09-b09f-6f9a1025f754 0daf63c7-084a-4ae9-beea-f5eb2319554d fd23ee33-aa24-4eef-b48f-4c03a8b78b03 f147ec3a-2bdd-4f6b-a954-957c5d823d0b 5e878bce-d9dc-4fa3-aa85-b1c42c440fe7 9a0499de-aaf2-4e18-9206-14a882ee273f 423eaab4-c940-43df-ab1c-876725f13331 865d3ea6-ed38-40bd-9e61-d4139da1d9ac e87ab328-62b5-4db2-8118-f1abc10ebdd7 6ef102f6-f472-44dd-9b91-487801421aa8 9d77c2c1-e127-425c-a6df-06eabe807b71 a3c396c6-92c4-4b88-9b15-ac440357223a dedf11dd-9fa5-4d39-b0e7-d13a67fa2be9 68703391-18a5-4c29-9f30-aa4b8024f4c5 9fe7bb5a-85ed-4c80-8cd2-4b8ce61e2b22 2d38acf8-43d6-4816-b182-69d99a12eca8 cd4f7ce7-5c61-4c81-adfa-f2f70efb2bd5 903bee17-39b5-43eb-a94c-4ef9203c255e a430965f-58ce-4cbf-baec-ee186dd2a7fb 4f45b533-eb9f-4aa7-b18d-cd9adb3849ce 54b85629-bfec-4d88-bd4c-1ebd1db2c7e5 a3915512-b9df-479f-bf29-368ffb3409be 37741287-a809-4a7b-b4d1-6db29bd04299 3c3b78fb-698c-4220-9b60-a2e522f80918 6a61826a-2bce-495c-8da8-0bc928ec97e1 ae04c7f0-8454-48f1-855f-fce10269cb06 9f8b74ce-da77-49cb-ad4f-c743770e435b bb5bfa45-f6aa-40fc-b481-3d928291b7e9 079bf363-98d9-4265-8bff-a00340115b59 c234d4c7-1fd5-42ff-bf68-5a43b59c4d5d 346e1674-aa40-4a39-b294-15c692c9fd48 28b7e4d7-642d-4848-af7c-f158bfef09aa 4c4c2625-bc33-4fe1-a18b-0e478a620d37 29780f0f-073a-4bf2-a2e3-a864c36c8e9a e931c9e5-d2d0-4b47-80ac-814eea357a77 ae2e2f1e-4a77-4b7a-b93f-62cd8f53d436 dab1b51a-b0a8-497d-886b-790714c6b9a6 951cef90-3f07-4720-9274-7838c4bfe8fb a876e53e-1788-4be9-ae86-a28e64166acc 750b9ad7-4975-497e-94bf-355926b0e64b e27a7234-b2ac-4403-add0-dc204f2eba08 3378df75-43f2-4ea2-aa4c-327d7b0ceaf4

## 3. Inputs and Contracts
Input: Profile metadata for import_history().
Output: Script execution status.

## 4. Execute
- Write import_history() in import-chrome-profile.sh.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "import_history()"` or `bash -c "import_history()"` depending on the environment. Expected output: success for HistoryImport(SH).

## 7. Done When
- [ ] Criterion 1: import_history() is implemented.
- [ ] Criterion 2: Linter passes for file scripts/import-chrome-profile.sh.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.

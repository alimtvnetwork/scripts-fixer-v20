---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/import-chrome-profile.sh]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section17"
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
  tests: "unit test-17"
  ci_cd_guard: "linter-scripts/check-bash.sh"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 017 — Importer Profile Prep (SH)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for ImporterProfilePrep(SH).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Validate JSON schemaVersion. Resolve target profile dir. Create if absent. 10d7d99d-d7f7-4fc5-a26e-45a11857bbeb eea3bc8b-3780-40a0-8899-4b1fdee6871a aa49eaf5-a3cc-4b3d-b4d5-b5fe3d08174f 30730b31-81e1-472e-8484-504c5348384a e712a418-ab29-418b-8c27-6006414eb5f2 8c3b84bc-bbb3-48f3-8e15-71cc032b9d3e 403a73e4-c380-4d2c-beb2-6f8ff861d185 07fabc10-a81c-4208-bedf-f389bab8b808 28d55e8d-f1e5-417c-8258-03256c4f1536 787c509b-4a5b-45ee-b82d-6fc24e573e47 fb959480-2dbe-4ea2-8e5c-cdbacc5f5154 4aa4e6ff-f208-4688-9f9a-7ac918cc9ed9 49dbeb03-cc97-416e-85d3-b81bdc4614eb 7747a583-c1db-4db7-a06b-3ad01054ff53 7eaf121a-0872-4f50-b359-766927edf751 6206bfdd-b9ee-4a90-b35f-cd42447b93df db116bcd-1b63-4787-b624-ad0b9a9162e0 897a4c53-b266-4def-b80f-4ea0e381643a 27008081-bc2b-4ef3-8c05-6c10dfa6e699 83cfdbae-be3e-40e9-a7df-d7ebbc55106c 90d4cac2-88be-4fc6-b89c-17515c63afb3 53a749d6-e60d-4d98-b894-166d3a5295aa b9dcb083-e4a2-48a2-9acd-af77bc325c90 d829c129-8ad9-4ba0-8d27-c98daa90bfb4 63c36b38-f65d-4e3e-b243-0f15bb3663d0 dad0e579-00aa-4f9a-a6a0-167038e4e2bc 7a8b1452-ac49-417d-a267-29184d09dd77 57a0ce42-2648-4c8f-bb2c-72fba41f18c8 1ebd85b8-76e5-4ee6-8ee7-43796351ecb9 42210998-a893-42a3-b410-071b46720972 3abfb315-5355-48fb-bfd2-ea304de0c7cf 915e1da6-1953-456a-a9ef-0468cdd72402 c11cd031-2009-4359-afc8-b88614c32da7 8624a7a2-272b-4f7c-9ddd-43ef6e80045c 51cfd5e4-b952-43a3-940d-953c468d0205 b3e5f8ee-8b1c-4cb3-8850-84c0cb67b0f4 3635cf2e-d134-4a4e-b4fa-2e57cadad526 00a74321-9a77-43b5-84cd-bc54123221f0 f8ae3b85-e884-40c8-b69d-325312cd98bc 865696d5-49cf-49bf-a6e2-99e03aa888dc 4a8a0032-d729-4d77-bfc6-96f906af38b9 034fc05e-2e76-483a-9252-d695d809124b 237a00a5-bf5e-48c3-b798-95d3ef542c57 e6c24d01-a5d9-4215-afea-8a2b0cb584db b2c88bb6-d224-48fd-9190-421b2926c3c4 2d799e77-560c-4e06-8a63-0eca23b22d10 610093f3-4730-424c-8787-0712326a35be 15250b41-f21e-4af7-8df9-ecaf4c8070c3 7abfb366-28c7-4f48-bfdb-e598401234d5 012f849c-06c8-4f8d-a171-f9a1a3795113 08bf876d-020d-4878-9d55-dc542af65380 68bc9ea6-9d49-4e2c-aa4d-ffab9d59ca05 d037b0e9-eb21-421f-9d97-a2f10e5a5778 2519088c-9c2c-49db-874c-0de31121c9fe 3dee58ff-8ab2-41af-905d-e446e7068730 e21c0ed2-7979-4074-ab69-bdb9c87a6b30 18d2f00b-a760-4962-9036-8567fb6bf738 8b9d7958-b47d-471d-9a73-194db313bc53 03816143-0cd2-4ae7-80f5-89d469a3e3fc b65f64cc-da82-4860-ab8d-310dd6e72de6 7534dcd3-b47b-4654-8886-09bd23af1e6a 7c8b3353-b203-45f4-8590-6af573110134 a5473d72-576d-4475-91b8-ae0bdabe3f67 3a6ee563-cf4f-48ba-a467-9710bebd8b6a 0a94529f-2e5e-42b9-a45b-8bc247125da5 44840bfb-7d03-4183-99b4-714847be7e57 cd2c03f1-eac5-418b-af23-3388707e40c7 9f206499-31bb-4fc5-81bf-4fb0ea085038 d13fc6c0-4d58-47f7-b84c-cb90c2d2fc0c c870d7fc-005d-46af-ad9a-7e6fc0daeaad 6b9140b2-acee-4ee1-bc1a-c1ef8ccef2f4 5690c09c-522a-42fc-913b-07ded4349f49 b3aa2303-6a6e-447f-8e4b-c4b87e448624 6ff199ec-6710-4c3e-a742-86f984674c5e c288aee2-d480-49c9-8810-0cb83cfc9745 aa51856d-191d-465b-97dd-92bfb7d45a2c c4c05ddd-a798-4943-857e-5929fa7b903b 3f124ea4-8eef-41ee-bce3-6aa12007d458 7e4a176f-222f-4efe-a9e1-e5e1ce4beef8 ec6469be-4302-440c-8e41-258b8d8b02df 4ea4b805-524e-4850-a137-0c6af79d8c31 d2d57f67-af4c-4111-af67-553e475246d6 1afb8b05-a6c7-4970-8549-fc9ff7f54a7e 13027059-6c68-4f23-a71b-4b925af87dda 74690d85-3afb-49ea-9c90-191e4ce56865 a809f229-401a-42f9-98c0-2b8fdc8a8c33 d42ff64d-c52e-490e-94c1-33cf451ce7d9 58f1745a-ff4c-41c8-9fe2-58cec110b26a 8cd4da63-7e61-4f5f-8c72-85d9a1c1f570 26cfb0c7-9e8d-44e1-9dbc-65da65baf3a0 ffca7151-06e2-450d-83c7-c68256ab0694 f6a3e31e-d7b6-4fba-8517-174afa4e7cef cea90c15-54e2-478a-b2d3-d396f668829c 1ce734d8-adce-467e-be5d-f3bf74af5111 07881ef7-37b3-464b-956b-efb6d7c80afe 3b5927bf-50d3-4363-90ca-a87ae7e6abaf edba1318-5931-423e-a58a-f02a725d69c8 955204ba-761c-402b-8529-ed18933f66f9 769c6936-1aaa-40e4-92ff-952bdf4f605c 4a6948ae-dcb9-4a83-ac79-57bcb70e1e4e ec064b95-c366-4d3d-86a3-03d1cec55496 155119a4-0fe0-4b34-bf5c-2e382bd08fed 5643561b-7c8b-4c81-88b2-dc33749d982a d8f493c8-4185-410c-baf6-6caefb35c996 84d60ac4-1b2c-4e4f-82d1-e379232b157b 53ca35e4-07f5-46a5-a6a6-63b4dcfed68e eb97f568-aa39-48d5-85f9-b57238e2ecf8 ea30aa0d-490c-4adb-8654-c91a879aab06 b2cb9201-9dca-4ece-87e6-d4a83f0bda84 8c65af73-e15b-43a0-8ae6-850c0da6973f bd2a276d-0708-4836-a817-a0460378aa60 ceb0cad5-b9e2-4056-a1b5-8219b798010f 56d29d5b-3c1f-4400-ae48-51551ba7a7ff 55d33658-e2c5-44bc-b598-5c9665eb55d3 5e85fe83-003d-4694-90a6-63e36cc5a23b a65a1098-7b08-4472-a7f9-3cabaac7ab5a 79ee770f-e9d7-4095-a2eb-de6324de4c45 a14ab52a-b762-4cc0-a2de-733d21413346 09daeb65-25ff-46a5-bc2a-0cf38d269bf6 ca512585-d338-45fb-8eea-43f98e671978 239be1a5-c591-40a5-8a82-5b76b3c1cb70 76fbf3f4-792c-4699-b4aa-84eed9158c49 27c66b60-b2e0-4a46-aa9a-2b1b01bee8be f8ed03ff-f273-4805-9eaa-bdae2c343bf0 e9abce54-03d7-4991-bd7b-8f55076d2044 17611209-8baa-478e-966f-a64a1d58628c ffa3606d-231a-48fc-9de1-ab8aaff9304d b01b4817-1258-42cf-8be3-eb88775b58bc 6e1cbd83-e219-4cf6-a64e-0c4994712f33 405c4067-2202-49ad-abc5-4cacc4330991 996fbc65-49cf-43e8-8a14-f44b62e0c131 6cdd882f-12ef-4643-a47c-b197e1c47d9c c97d5a5f-e0ae-4eeb-8ef5-652adcde7b51 762e3823-50eb-4465-b5ac-f44e3f6ba8ed 170fce01-a188-4fd1-a42b-dbbce54d3d1e 77788bff-3f23-4ad2-9d54-0a7c060c4959 e0524cf7-f57d-4e72-b35e-f72efb5154d6 1d0332ed-0b2f-456c-abee-af73eea9dc2f 29b2747b-36a0-4d18-8eed-f718e6c38305 24b4bbb8-38fc-4498-8ea3-c14006aac75b ee7abe27-a7b6-4da0-9a11-b702e048171c 7e29c6db-63aa-4aa2-a08b-96fb35972e95 bd480d38-bac8-4532-9c79-13a989831524 44f0f11e-cc50-4416-821f-29f75265c54f a85c48d5-7e55-44fa-81bb-1b183db8fa5b 7b5a7571-ed55-456b-b931-c89ac622ac56 d4fb65db-1d88-4964-ac1f-9155c6cb5cfd dc8ada22-4875-47e1-8fb4-2590afc69d15 06db6aba-40f1-44f3-86e5-82428bfd785b 7f150128-f310-48e2-87eb-9068a9ea3e09 0433eb2a-6dfe-4793-bfd1-945bf1df8e01 df931baf-43df-4096-85d5-c8d5a1560e49 e17e4222-8edf-4970-a4da-b5a55465511d 95f5b76e-c459-4130-9f30-de235b67ce38 52c936c5-5327-41bf-a8e6-1721d06402f5 95914c14-d876-4026-848b-5868627f0ca9 fbdaae39-c6dd-4562-81e6-67b1c2d1584f d97984d8-c831-4b81-a92e-c2e90128aecb f65c798f-29be-404d-bdce-9ac4471a9df0 55bb0377-753e-4977-966d-d2e6d564fd50 d0d4bce7-5992-42e2-9600-26f9e48dcc42 46bbe119-e27f-43d6-a3b6-5c303cdb9ab9 aef09ece-4ea2-4deb-b8f1-1cc87b64f19c 36aea984-855c-455c-99fc-62818dffacfa 0a6106c5-0594-48dc-a5aa-e0bff6fc146e 2747d62f-c629-47e6-821d-52f458019fd6 216fab44-d007-432d-8f9c-48f728aea259 e6c7bc0c-b066-48b1-9fb7-7388795f965a 73044211-2834-4002-8975-df2a494877cd 1317b2f8-c80c-4f42-a63c-aa2316097eaf 0ebea1e7-8bb3-46c7-a27b-2ed797b0975f b2970b3a-a934-4243-ab88-61591dbf019a 3a226981-6c0e-430c-89ca-99abb7bd7e80 df912960-923e-4c27-9f3c-eb4c43de61de bac179dd-e8a8-4906-a401-476051992cd0 fd7f8bf2-4152-4614-aa4d-99522a1cd303 d73bc65a-c790-4b6c-a67c-71fd399a5dfd b17e09f3-751c-47b5-9503-36040e8fed26 f47ce792-daab-4413-8db2-7662726c289e 94e96a30-d8e1-4cf3-8e74-074b5ad4a973 f4604a38-6e38-47d5-ac21-5fbf10a8d9d5 38366876-3882-45bc-baa8-db7a1029792e a4b516f4-af4d-4151-b54f-1ae7a1c36685 02656461-baad-4f76-b4a3-26d279fd4882 b9884613-f1ca-4c72-82e3-56a77dc5888f cb643dd0-118e-4af3-966e-eef8100d2212 0a032f72-41c2-4952-95b0-0e0b08c55ebf b7f8cfe2-a077-4273-af37-d9e4e978840c 5e60cc6a-c36f-47fc-80e8-fab92e53f3bc fec1b7a7-6d8e-468c-bb86-3cda83b991c2 efe8f26f-8de3-4114-bfd2-7581bb371c05 9bf951ff-66b2-45c6-a3e7-60742fd821d8 86a278be-3762-4e3a-b475-0e661074fdfa 57df5af4-0729-42af-862a-0b5acfc4a4ad af7cce13-ea20-4bb2-acf1-8057f9b12599 0a74ea34-5549-4b13-8e88-9180aeb6900b 35d77363-bf7f-429e-b318-15aa356ddd08 0c453012-833f-4963-bf1b-d57276426765 60f79815-3451-4253-af47-459bce03fc0c a82fae19-8ed3-4591-a6a6-e8c9e4c1838f 6716f7d7-96a1-45ec-81ef-f5280d34ee89 c161176d-0ed6-4c14-a29e-5758da57d13f 993b3bea-12ee-43b0-985e-630d9a862a9e b6a723eb-bc6f-47c8-8817-6d79604a8368 0bb12a6c-9b84-4b4f-a4fc-b72068bdcff7 5189d16a-854b-4b26-9d69-f5eda04bcd4f 168bf282-7251-4453-8a45-7a1783ed7174 450b4e71-3a2e-4098-b98b-7f54eb506c06 31685e8b-e70c-47d8-ad75-a4e4c0039703 4bf3d197-57b8-454d-9bfa-e62623834693 eba41559-48c4-4d5e-b12e-663fe761a3dc 9c85a5cc-70ea-4fd0-9165-f1312e6377c9 bbd04e8b-06f8-4585-8610-7413708627cd 4841dadb-cb4b-45f9-aacc-6047a13dff2c 26d55008-6800-4b2d-b117-53820d23fd72 616b27db-ecfb-42b1-abc5-f4eb21e091d7 d23586f0-c386-4def-ada9-c9e3c8026df5 81282a34-b9ac-4d65-af65-08332b2f08b9 303b7f75-7eb5-4256-a252-b51a67abaf69 e1e3be47-67ba-42f4-8544-b7e8edba6751 0e3dbb47-4ac7-4eaa-bbc4-8fd1267eb417 055c6a39-e06d-4794-bf10-fadaed3070ff ca22be48-ddc8-43b1-8e91-b41053d0cd89 4bdf875c-e4e0-4981-9327-5b2f47688830 9e4b0d24-7ece-4c57-ace9-0a46798987fd 60e853cc-d1f3-4c07-b0c8-f2c195ef3026 f863faf6-1428-43d2-be52-ec2cf86c3177 a169f47c-b620-4042-aaea-fa1111412638 1dd0a71a-04c2-4586-97ee-b76c964dc9ed 421ccb80-f891-423b-ac7b-0c2ddfd4aabe 72e210c8-5f09-4840-aab9-80428aaa6d36 28952007-ee07-4b5e-a1e9-a03eb709a0ba 3d6f7ba4-37eb-489d-bfc4-40ed8a6e6844 efd7b5c5-2b8f-4071-a868-6323a2c878b4 4e7df1b1-66eb-402e-a2a9-867d0a72b157 fa3ed89b-acec-46de-9863-2f3e244697a8 d7ef1114-0937-466d-a91e-deaae0623514 db78d736-9682-49fe-a1b9-40aa7ce840cf 9dcf3247-77eb-462c-b662-fa92e7883598 40792fed-5b88-4bf8-a910-9d066bf2cf9f 017ecacb-8410-464b-ba82-3cc8fe5762d2 51b4b85d-e047-4b1b-bad2-c42d5cf76cd8 23c41515-8bd8-4ea5-8221-22d64c205c57 b59a8480-1a4b-45a8-ba16-de6091c002bd 67f2c84e-6975-4fa6-8d4b-32619cc4d687 10572213-ee19-41a8-9c1e-0bca7d0b8030 938a85dc-ac0e-4b2e-94b2-c720bd5d51c7 36665c32-ef75-4706-9d54-c8c3d9c9a545 87225cff-39fd-4cb7-877e-8cf5582e978a 5c036430-8ebf-48e6-87ad-7aa471300aac

## 3. Inputs and Contracts
Input: Profile metadata for prep_profile_dir().
Output: Script execution status.

## 4. Execute
- Write prep_profile_dir() in import-chrome-profile.sh.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "prep_profile_dir()"` or `bash -c "prep_profile_dir()"` depending on the environment. Expected output: success for ImporterProfilePrep(SH).

## 7. Done When
- [ ] Criterion 1: prep_profile_dir() is implemented.
- [ ] Criterion 2: Linter passes for file scripts/import-chrome-profile.sh.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.

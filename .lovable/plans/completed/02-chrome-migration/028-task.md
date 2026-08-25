---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/import-chrome-profile.sh]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section28"
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
  tests: "unit test-28"
  ci_cd_guard: "linter-scripts/check-bash.sh"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 028 — Autofill Import (SH)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for AutofillImport(SH).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Dynamic INSERT into autofill_profiles. Skip if schema unknown. ac896ed7-7336-498c-9133-5c945d16ad2b e45cd920-3227-4cb4-84b9-f2ee42ed3944 d11dc3bd-6d54-43e3-bdb7-c9d5cbf64e47 b31c14bc-1b1a-4455-948e-c63c2b487e6d 69442db2-0afb-45e6-8c51-fea1c609d3d9 06e7904e-a21c-4e63-b8c1-23fc3319af0f 3d3cf689-3fab-4e08-b7b7-1c689983db91 69b8f4f4-cd1b-4c5e-917a-e19a2dd434a6 ab99b7a8-5bd5-4a50-a3df-1727f8b34906 2e7fe1cd-3c98-4723-8918-90ee66c3c7c2 9d59d569-dde9-4f3c-9110-7107e6f93695 5a0389bb-3e52-43b9-8321-eb3cc388cb1b 5b4d8fe0-81c5-44fe-9ec3-2f032ef502a1 2b9613b2-1c53-4226-9976-541f971db23d 43c66df5-ce81-4abf-8a56-30b8e4f91004 2bb3f0d9-5dde-4b52-bb10-934711bd53ca 2f03b405-4800-4f45-a05f-fba79b7798d8 b1ae4b50-e974-4907-9815-d07cbec52dab 076de9d4-08d0-4d8b-98c9-96439c4aa9db a029dc52-4cca-4241-b9f9-dfb5574de5b5 595b60f8-b000-422b-b76d-0102c30d369b 86cf878c-49e2-4b17-af9b-c5ad9da830d4 96054098-a278-40a1-8f56-d6b9938de87a 49801196-f267-48ec-b366-7524e08b5e66 b5dbef6c-9037-4b23-aa58-8fc5eb6e14db fc9f3698-d269-4edd-9550-20beaf0733ff c1a81918-ec6a-4bcf-a942-2b276d607454 cdf43f26-e19e-4883-a05d-51ffe7da4135 609b377e-1046-44cf-a7a5-a841476cd490 d136258c-0e11-46af-a09a-a021690f9b39 ea837d03-c498-4673-91c6-8d3b5efddad1 87bed9d5-0ebc-49ce-a1ef-6108728692ae d4b2c76d-921a-448a-a343-82e73dbed249 f527ebde-79fd-42bf-a526-6482abc06bf6 aece4396-e214-4c7a-9d0a-bebe33bc1248 3882d673-9654-4359-980a-85adb3e188a1 221095ff-78d1-4bee-86bf-f7c74b460be4 593f8b8f-7e53-407b-886d-131c660490b3 52616a81-320d-4b6a-ae2c-ce56c887bc91 6233842c-a090-4b68-b64e-c1f7a51477ee 04f561f9-dd87-48b6-99d5-970628703a6f 050c8be8-73b2-46a3-972f-cd27bd0d2432 f317cfc9-cb27-4917-8171-db5bbeab29e8 0d17f239-ac86-41e9-ada6-4a6bac8f909c df5521dd-d0f6-4fa5-ab0d-a5be3dfb426d f2c92d30-b76f-4294-9317-74053184a44a e2ad998d-3c17-4c1f-aee6-565b927b1c98 1fa308d6-d10a-4ef8-beb8-dac81958cf54 b8bb55b3-091c-4b04-aaf5-db34e3f8c6df 8e36de54-4285-4c55-8a36-6bd6098842e7 0d0cfcc5-39a6-41a3-a11d-80eeaf0b2534 e6558710-e886-4f04-9c36-5a20039918ac 84434987-6bf8-41e1-92a6-64c7d70ee75c c9ab009e-53c7-487f-b10d-97e993f96ef6 8ffccbff-2f28-4934-8d4c-56d5a5f087eb a0363784-16a4-4b6f-9660-da3f4109ed5b 2e92290c-7e86-4288-9bdf-8e3424b4694d 5da4ef4e-18d8-471d-b505-3364370cf37a b5b23a83-caf9-422c-b2d2-2feefe20a040 289bfece-801d-4a64-8323-2636f06fda34 861e7a4d-aec9-46b5-9e80-31a41869c118 0ba0a413-b452-463c-9a88-58270165076f 7c337c38-9f2e-4288-93ab-c4f640c37761 8dd518da-3f02-4e72-a524-7f319658192c fb19619a-88f5-434b-afa7-0f17d5498fd0 758d66dd-6732-4403-87dc-7979641c7238 2cdafa3e-4387-4031-9fc9-0decc5dca691 9d20869b-904a-44ce-bf54-e992e858441d 8b4a2211-0133-40a8-8853-297d19df2b6d 881a8842-c64a-410b-84d4-c0298ee45a44 3526924e-f427-4eac-8026-b4df64d40d63 7c78da86-9cfe-4438-852f-2ba763278cd3 ac77f94d-e277-4574-9d68-e2da2a64cda1 39dd4651-d151-4913-8362-ff9426c34f11 00ce7409-19fc-4a48-9fd4-41316e8cc3e3 9a1c701f-9aa0-4af7-adf8-d58834b7586d 1430f5c8-4c67-4b2d-a324-4b1323440e3d d43a29be-ea2c-416d-b626-adf5a931cedc 23832f19-e82b-4f4c-8e4f-d1fb83418c9a 598ebddd-70f7-4eab-8ca6-9b14f86009f4 f7bb57ca-d279-478b-9074-25b62e52536b 11365e39-d1c4-4568-bf9a-7f5235efe81f 8517d86d-9614-4c64-b6db-b61d45bcc2bb 10f5d9d5-ad45-4bfe-9b06-783a59ee8d90 ca498cf5-1809-465e-8f45-7f92df7cbd11 9596fa0b-0aeb-41d1-b3d0-f550c42677f9 c20ed55d-c221-44f9-9de9-7d3b853b5b37 3a1f5e7a-e213-4ebf-9c4b-01f8f09a5198 7db21fa7-5505-49b6-b434-027c78b7445d 1a54c3e5-50b6-4294-bde0-82e625466951 105f0bdf-ab00-400a-9698-8743a5d427c1 36890c63-8b0c-4ce7-adfc-396dbbc55340 ea87bfce-1bd1-42fc-b000-a87f9bd12584 93a7ed45-a82a-4bc6-9346-9784c03b4193 0e46c42d-3ab9-454a-9b89-5c880c4c3d7d 4eb512ff-e46a-4dee-bfb9-433584e1cff9 f883a879-4be7-4019-9526-3f43c197c513 9d7ec0fa-be4c-4a2d-b8d0-472c829c8c1a 00a7c2b8-06f7-4849-a76d-3c8bfadd8c2d b9ebc894-9535-401b-b50b-9587fb865a56 ee9514c7-c2e1-4c49-8919-999fb3f42b99 df12c6aa-14ec-4703-855f-95318810277b ec6f3320-4ece-462b-867b-a218835e528b ffd115ac-0387-486e-b4a8-2c4278b6711d dfdfc697-4bb5-4a8b-81f8-04c07a39eeb8 bafc3c65-adbe-4c15-a6fc-037e85e829a9 ae175832-572c-4528-ad95-c00b02d705c2 08e2ce66-d20d-4e64-a0a4-08602b68c391 3bec4b58-abe0-4ff7-9a9c-807f50a1207b de9c858c-5d39-4a19-a644-ef5e8f699b87 55cb3863-4d21-4eba-a9ae-74ac26ab44b5 b8cf1e12-adea-44b4-bc5a-6c17ba994461 d5b42000-ac25-4d96-8a1e-18af0f6b814d 004a8c89-e050-4eff-bf6d-f20595ab2f8e c5e51e29-04a5-411d-a67a-58674ab57aec a15141cd-837b-41f6-b270-da3486eb48b6 5d27b537-f6a9-449a-853f-cb672fe9ba9c c9e85fee-7be2-4ddc-bedb-9ea68edb8f5c 2b6b68b1-9e04-410b-a077-1c4a639469a5 b0222e40-ee46-4e45-b432-0fb3f079dd43 3764b341-ff5f-4a55-bfd2-fcc4a7447494 c9bf865b-9163-4d31-a34d-353855122a17 6b332fa4-7947-4229-8ffb-6efe7aed67a3 1941ad01-2f96-44d8-913d-df96399cbf8a 92e914dd-7740-4ef5-8ebc-c54d3d2613b0 60c31880-81a3-460c-9214-b247f6d6c15f 880334b8-190a-4132-82e9-354cb82cbfdc ecc1e139-9a09-4440-9983-4990e3f21b4b 05b68bb9-c4bf-41fc-9cbc-60a7e1b8c061 1e9dbb54-cc40-4120-bb58-9cf4d8ad11e3 faf12029-2136-4075-a666-490680f43ce9 db060eb1-a57c-4493-82e5-fe1c886d1a7c fb8d6cb5-bbaa-452f-984b-1f3d860b1c13 9baaaad5-3401-437d-9bc4-8c6b704eb0fc 3d6a47c2-01a8-456e-9e1a-41c8603d465d 11d5e1cc-633e-4f67-97e1-8d2874855f9b bb937a87-ad9d-42c1-b36d-d28702ce4afe e04fbd9a-f902-447f-a27c-601f6118bb78 d4bf0baf-2b6f-49c0-9765-939c0bd5c17e aae42725-20ca-4b87-9243-a395238565c1 13ec7fba-23e7-4875-aa65-c5599ae40ba6 70d4c7b3-6c19-4f93-b7ed-9dd858b5a637 31cc6124-414d-4d02-a271-4ec3ea77758d a915230d-f080-4c35-a670-26d43ce3b97c a424630d-ddb8-462b-8838-a34a94a02450 f16cb799-f3ae-4c9d-8981-66e92638bd6c cc2ded8f-9566-48e1-af02-919c7ff90533 48ff886e-5c40-45de-9644-0b13c453780c cbba1f57-88ca-4aa8-a5da-77d1f1630063 78cfb753-1540-482d-9989-465ddf919e51 67e70afe-883d-4585-ad81-29b487385cbc 44a9fc72-b9d8-405f-89ac-e79583970bfd 68329276-c5a8-4d53-8b52-130dc577df4e 209daaf9-db47-4918-b87b-7df08099f386 b3d60f04-045b-4459-beac-ff24ef29fc42 2052de22-1f80-4559-8814-6279d0c5f56e b3507bd9-68df-40f7-be38-1a32dc485e46 d9a5b73c-c6e4-4020-a798-6fb9fe9765b5 8dc24fa9-7294-4de9-b4fc-b97380ce875e 7ce8a551-4e7d-4c68-9bcc-98eecdfdf6cd c5ce4ee1-223c-439c-b7c6-e49883fd1376 d6dedaa2-5927-4d5f-ae9c-ebfce5bb2a63 127abe13-2f11-426b-8e40-661a9cee6c83 a3c30302-a09e-45f6-958f-f50878f5cb29 de67837c-3642-4fee-a966-8ac0af5dad92 d9a8d423-1ea2-4bc4-87bb-d5adc1a09a41 25fb1133-1ea9-422c-a66f-57050626b54a e88c17a7-118e-4018-8dd6-8828e97ff750 f8c82960-b570-428e-b549-f39a1008913b 1b186771-0839-4696-9991-ad8c5d879655 52d7d755-3d49-479a-a089-d74116cbd2f2 3976faa3-e065-4a1a-927e-74ec73296c85 912f93d5-d78b-458d-b52a-46ec2da21124 65528563-69a9-4ff9-a80d-06a9ad309a50 dd203c32-fdb2-403c-bd7d-dc75d0db5471 23ce71a5-8597-46cc-8c97-7036783740d2 f6ce7458-be9e-497c-9aa7-6a6ea754154c 1ea684d4-32fb-4d59-8edb-83c1b79457d9 7b28c11b-06a2-4828-a095-747cb1e2af9a a3aa519e-a548-4df8-94fd-4d1abf687b81 abe04dd0-83c7-4ebd-911e-d6e15f9d9817 68e91b12-bcaa-4126-b1e0-ea4df0b4c28a e9ad59c5-fbba-4541-bd04-96504f73139f 99c15be0-b113-4686-b43f-9ad0f5411c0e 1549e283-a4c3-4398-9aa7-169da80cc65a 52bfbd51-3596-46cf-a5af-cd4f556e1e3b 59e643dc-b621-4707-a183-1837a86c5906 d78f1c83-5e6b-49a8-884e-cc8698217ef9 b838dc22-ffa8-4852-aec7-1c4661bb53ec 2585c33b-44b4-41d1-b00c-6917ce8cc55d 4069cd59-5330-44c0-bd85-b7d39d9ae192 7dee0317-8d41-4602-9abe-fca14b74fa4c 5d76232f-9e4d-42e2-9905-88a537b10c5c 64ceeef6-c42a-4fc6-9f38-3eece8af553d e936e110-c20e-40ec-8552-8657aeb2f7f3 43b5b78b-f63b-44ae-b90a-61a482fd5843 b40f9528-51ca-40e9-8772-6448116d75ab 824ece85-d9a8-4fe6-b206-01aad5b5d41e 7e427367-ce1b-4247-816f-3f8f7ccf988d 1f7e9e78-8717-4ddb-b84d-523b002dcf0d 6eb1e2cc-6709-41d9-8351-3ad52bc565e3 e53a637e-236e-4dd1-a543-0fa2679f633f a6f871aa-0a7b-4001-9173-a6df33d355a3 0e085b92-6c97-4ced-8208-a0cded4d90ed 99eb3bf5-8076-4c29-9df0-6313b0cd5cd4 ef73cdfe-dd84-4e21-9522-f171b1ca9f4c f9fc7381-5573-4dd8-9dcf-9bdc45f0959a 0fb8f2c9-a7f8-41fc-bbb7-c909cac3e174 5f0affce-ef29-42c3-98e2-af4164f6dbd4 bac59059-0d4b-4462-8421-3fd9a01e87a1 cc3e1b6f-7663-4eed-9a5b-97f42d825d94 a45b5d78-0e81-4689-b5c5-39c1ffc5ff14 c3bc2c54-c42d-4425-a91c-f9271ec93e09 2afaedb8-c645-499a-a920-2a046d2e417a 345bee11-ab92-4b89-a059-0bc1396f4ac3 96775639-fb69-4f9f-9705-e0f8d8ad6e33 1f2b0416-89de-4f51-bb78-a19b0805498e 818921fd-9dee-468a-9b21-624017d7ed9f 3a840ace-9767-49b7-a7ca-ee0e2e90aaab 8e932e1e-1e16-4ecd-b4a8-f3013dee8da4 99fcc2e1-0cb0-479e-9aed-aee5df873434 06197af3-1df1-4ebe-8d1d-6339a2d565e3 fbf4c03a-5fc7-4902-985b-5881df55a326 cf961b25-60b7-4c8e-bd06-828f410fa1c7 fa9aac56-4da7-4459-85ac-1112026f09a8 8424be35-9edb-4a5c-93c5-81954e526d26 612425ec-ccb9-41e7-9b48-4049c94aa401 e6ebe3db-88f9-46ff-8382-9e3a4af23a2f 228f24d5-cffb-406f-b165-ed5579fbee15 c4864a3b-52dc-4b5d-a72d-0f27b839e3d2 ab64832c-8cac-4c45-bd0c-b83d29bf3863 0c3c302e-4605-45f2-9686-f319a47ba692 8bd741a5-ddfd-40fb-963f-9d28963cce21 2bc24b61-a979-4c38-bff3-67b47c1579f3 0ee68795-6895-479a-8ca2-50dcfdf427f5 b42ce6f8-4736-49b5-8e92-4669dc82687a 0b794cd0-b062-42c5-807a-62d0f5367830 49568806-dd85-4804-85a8-43e7c6b0d648 adc33d40-51ce-4f06-be2a-aae7d017d947 cd568ba9-d77a-4f19-9324-4f868cec8d89 a16fc706-3ee2-4a88-aeb7-3fe14c22cc67 99a55923-24bc-48e6-8b2f-1cab4e66db0a 1189426c-24d9-4c64-b136-955866586306 15abcc9e-39de-4516-b79a-f2bac18f5cf4 18c291f7-58c4-4b95-a413-ef3877e00690 62ccf2f5-0e37-4eff-96b6-2cd556129b0c f34ce3f9-80bd-417c-89a2-088e83d8d877 0d79d883-17cb-43c8-8be0-ac461d637e70 bc02197b-5c99-4907-804f-24d8cae6eac5 73c17ba7-e98f-4385-bfdb-c4338a8fcdcb

## 3. Inputs and Contracts
Input: Profile metadata for import_autofill().
Output: Script execution status.

## 4. Execute
- Write import_autofill() in import-chrome-profile.sh.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "import_autofill()"` or `bash -c "import_autofill()"` depending on the environment. Expected output: success for AutofillImport(SH).

## 7. Done When
- [ ] Criterion 1: import_autofill() is implemented.
- [ ] Criterion 2: Linter passes for file scripts/import-chrome-profile.sh.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.

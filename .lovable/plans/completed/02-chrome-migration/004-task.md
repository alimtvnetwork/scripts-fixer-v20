---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/export-chrome-profile.ps1]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section4"
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
  tests: "unit test-4"
  ci_cd_guard: "linter-scripts/check-powershell.ps1"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 004 — Bookmarks Export (PS1)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for BookmarksExport(PS1).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Read Bookmarks, extract .roots, strip checksum. 2fdce329-2b92-45d4-8509-e19cf3385bdc a8bf4176-c3a5-4f67-b5ac-4f4d4275dbca 07888bb0-6357-4c2c-8b00-fcf7e596618b 5cf8a274-2481-4f2e-9024-a15d2cd787f4 54400766-2f93-46c2-ac8b-4b88779ce802 a1e9005a-81d0-4bef-b592-ad039c3bac0a 111b3c29-288c-4eb8-b4c3-9ecca21ccd35 6d40a25f-1f0b-4349-a385-5800a7ad2e79 95103aa6-f78c-4f20-a5f4-eeea02d5d347 3c243f91-066b-4fe3-ae60-94843b5fb47d def2d4cc-4b17-4c92-b7d9-66ee0b5a2679 9ebbcace-571f-4978-b06e-cb540ee82c51 c0d8fb08-a633-49e1-97d5-ea2ef406a105 23aab8f2-632c-4f22-adc3-85156fca78b9 95cf4d65-e982-4e84-ac59-26a2f6c14502 2ea19d10-ff41-4992-8437-0d199f9c190d 83b99ae5-9af1-4588-8c2e-a4a9398d95bc 014df9b2-8d30-4450-b00f-fb04fa5d513b 26d714ff-c3e9-4081-9c89-35e91da575bf 498af6d9-4a1f-4ab7-8b9f-d98a93bbd991 5f8ebd1c-9853-4e05-a047-7680cc1d2678 051c99a2-96ce-4106-9d68-a59e2349d807 eb4343b3-7e03-475e-abcc-b48e1343d9f6 55591bd4-b320-47c8-bfca-6ce8351b2de9 5f15bf7e-c214-483a-b12d-c1093c46e183 27f2c55d-0c8a-40e3-8633-f9248f63c700 df55d4bd-b235-470c-85ec-c828cdeb9922 1e6ed45c-2905-4530-b4a3-154c5a9d8705 43a9210c-c80c-4523-8e64-669c03261239 b48f6ca1-41fb-40b9-825b-0d64efee09f3 698b5f96-9cb8-4d09-aa9c-e5a968a47f3f eb680f21-db34-44f1-b47c-cd7dbffe72b4 babfb758-2f3e-48cd-bcb5-4ad155c963e8 f3d83bac-adc6-4b89-a7c5-b4c3c28908cb 09b107bc-7837-4849-8715-e5c62e749db6 9b0ba833-de83-4bbe-897d-7b70545cdb79 76f4f3c7-a6e9-474b-ac8d-9f5854ffaef1 7ae525bb-0044-4235-89c5-fb4eec02ec49 88fa047a-9c2e-4080-a2db-dc98b5ed433f a2a8c18f-cf56-4be8-9935-eab395497e53 c8e4dbe0-2022-4aa8-81d5-b701e0eca706 e03469d1-28e5-41b9-a0dd-7a7f7fd2a3c6 269934c6-7215-43c3-a07b-33833a553283 6f156440-6e63-4487-9954-b0e5308ac691 12c240ad-6dbd-4d36-9ecc-018dc639b230 3546cea3-acd9-4c0a-8972-ab5e5f3d670c a824924a-ee83-43fb-81fe-171bcb2db1bf c2442dd1-e1fa-4528-b207-57ca60f31944 41dd83fb-7090-4aff-9190-1217dff94a90 224f9ae3-f5ff-4f7b-b6b0-0763c670634d e881d15f-3252-44a7-b400-5f28aa33fd60 426e8b18-8e4b-4dda-a9b5-0a19bd9f42d7 05525cd8-0061-46da-9f8d-982c2f81a168 d11fe0b5-3c27-41ca-a528-584c9a3ddd26 24cc8a70-e7db-4a0b-bdd7-b25821c2eef4 9189ff2e-64ef-4199-843a-525b196c0560 0e0af21d-c007-4576-b5bf-ca759ba2d4c1 08f37517-1a8f-4eb8-93db-fd01a89a72c0 83ba86a0-473e-4da4-af9e-91a68ac4fed3 87ad4e90-8811-4272-85f4-c799c71e7357 dc71ce1c-c6c7-4b48-85f3-9d677e5a3f11 dfe047ba-0b62-48f7-ad76-7778a3856f23 69ed9460-bc2f-418e-987b-ef7ed49a7b0a 801a13ec-879a-494e-afda-1c13a1135d08 ff08771c-b773-4910-aab5-792945b29c63 3e2d56c6-ab50-4955-b795-fa86cf5dca4a c7366f85-5cf9-48c3-a381-5a43ee8195ac aa6e840c-6747-4bf6-adf2-9baf0ea6459b 89fe8eba-29e8-4f7a-acb0-c9c886f6ae90 4515af54-dff9-4463-9918-44c986fe7b04 e9536418-1fc7-41d9-a245-a132cf17e59a 3b30d38e-23e4-447e-8700-a3277f52cded bbf81c7f-0028-4e99-89f4-39fde7181957 96170dec-1d4f-4d51-a8cb-e756177ab6f4 733dfe87-44e1-4fa4-aa7f-674defe14273 cbc953a1-0ecd-4463-a92b-958c76a4c6ff cb3700a6-b5af-4639-919c-6375244b5f14 7b53d2f7-eed8-4fa5-8504-79396bb5da49 c08429b6-e744-47c4-8f33-8ed443f26b2e c03b5498-d460-4c53-9c36-6fef41550318 ae56bc5b-ca66-41ca-84cb-136aff573584 d0d91b8c-c6e7-4c13-9dbb-730fddef073b 3868118b-27a4-4d54-b430-02d82f8d0fa9 db10b6fe-15bd-4885-b462-16898e3734db 5b8c66d3-f899-47e5-a3ef-f6b78335b2ec 51e3edb0-2747-4038-a172-d361bbdbdfb5 7ca43fbf-f94b-45c2-8f59-153efdb4f44f 95471e8b-5b9f-4ed8-82e2-88c098bf3d77 d38d0bab-91a2-4864-af45-2174d48b52a1 0c0606b6-9cd0-4644-a527-63c45e4502ee 23bcb495-95bd-4102-bdf8-672e5de9a64d 771a0490-3c67-4ec9-8e0d-50e442f776ec 0991fcdc-7c9c-4de7-b6c9-db0cb907c2e8 1091f73c-0934-4520-b011-3dc0aafca1de 7797054d-0a7b-44b5-b134-fb8af6cbf73f 68a642ca-8afe-4a45-bc74-aab48a2ef99c ee363462-ed9a-489f-a157-af3837963661 feee9c4c-361d-4c8c-87b2-d2fd13fb97d5 8e6d4d41-9fe1-4ed0-ac77-2245937cae8a 996e8af5-a1b6-4c05-a03a-53b3a10fe958 f85cec7c-ca72-4a58-b9d7-aa9457a664e0 1f805fd0-7be2-4991-bcab-117051ca03e9 13930818-cd70-414f-b50b-aedf77e5a6cb 2595add7-b58d-4531-920b-59445f0d8254 bfae63a8-2a80-4a8d-94e1-df5e86ef8de8 7b479b25-3347-42a9-be8e-9afbc1d58191 2d130854-dc46-45ed-aff6-a2b2c4abe07a 26a21be3-4c66-40ab-8a55-04e1ee042975 0c78434f-55f3-45c5-b6ef-cf1c37920065 7cd9066d-21bc-4b4b-8c18-864fe4646eed 1982fbd4-791f-4326-84fc-40b769573695 e77ed05f-0b27-4695-b8c4-76cd338f52b5 df628f6c-5562-46a2-a5c6-121ff4d8f074 18b2c251-10c1-429d-89e0-e1f054da488f 3c8357bd-fb96-4d60-8ae9-e5603540fb9d 397e0744-b5c9-447c-aef0-b0ffb9a596dc 5958ac86-1094-4455-8fb4-0068e9676af8 d1fd011b-4bd1-4d53-8152-d03e0d97f57f e2ea7425-2d24-4e35-a4f6-f318d17b25a0 13062609-6d35-4673-921c-d75d93a782b4 e1a933a4-f13b-4a70-bf77-0f934e04f1db 2b16b3f6-5476-42e5-8d42-91eea5bbf3d8 1290a447-3781-4b30-910b-5398120b7636 57181eac-b009-44f8-8186-043e73a4994c 7fd20a44-f333-4d72-aa27-ae207bfb4e39 e72a4d12-f802-4eed-8dea-3af9f73be4c4 72ba80f5-81f2-4346-9d7c-eb2604b077ef 79bda5ef-c23a-43dd-8a1e-ce32068e0919 4bf1385a-426f-44b4-840c-03a31f715161 b49b26e7-a245-42b9-bd8a-31bedd633014 fac1e9b0-b4a6-4e6b-b5c0-db3f25399dd4 6ddb1c38-3465-425d-9e40-3d6db8400e84 8a75d162-c3d0-4c60-ba2e-00a3b20a2661 a1db572e-f309-4501-9277-f44419d5042d 5bf065a3-5d18-4982-90bd-cb51e96f6b1f 831b7ead-1c40-4d4d-92a8-57b7d61690a1 f9c58f8e-9f92-41ff-9c70-b3669f4664b8 22afa9b7-e9a0-415f-bc71-7de1d5ee2fc8 fb8fcee4-107d-4d30-ac6a-d834696794ce 13944952-9ece-4fde-b806-ae51f8d8c0e6 a8c5e40d-55a7-4719-a183-bdb84de3b1f8 06fd7ff5-d2de-42b5-970a-8180201d94af 56a3efff-0d26-4d31-a2db-1cddac9f1185 c87f7534-588d-4b25-b910-3db49f542e00 a11e30f7-cfae-44ef-a909-29f24044100d 70e9819a-04e3-4702-9cbd-00e44c19e84d afabc039-93da-4a02-813b-2045df8b5614 e2199600-efc0-4530-bafa-cf7584feffc0 427d5f25-dd8d-49ed-b984-0329b6b524e6 d4a10a15-ae81-4293-9a69-64d97e7efdbb 1b58de44-f3ee-4a1a-889d-cdf11db30943 6be5a86d-2f86-4528-ab21-102a2fb3177a 8ebac8e1-1868-466a-86de-9e6760596183 d3674618-829c-4b41-a6be-347d84d7a7c8 3dcb112a-22cd-4ada-92ad-aeb6c9bc8f07 a582da17-2c96-4fa8-aefa-c8ea393be6be 65d57485-4fc6-44ff-9bd0-1a08cfd29bc0 9aae25b6-f24c-4614-ad64-c6c332e192c9 12a52f11-f547-41f7-b2da-7810d65424c1 28008b4c-c4c6-47e4-a3a7-6e2b8f69b0f6 2107933d-e2eb-4b32-b952-ce3612a5901a 0908e488-9734-49cb-a831-9e9d5f909c8d 8e6f4a2d-4c1a-4edf-b07a-60ec53b33bd6 91560ca9-bbca-42c8-8ad6-097bd4b9d288 90fee6e5-a290-45c9-8842-88c76767e0fd 4d8814ea-07d1-4519-a6cd-6ee5c542820d b3d7a22a-383f-4d95-a796-082a5d3b1c73 36ab096b-eb3c-4f6e-b135-823519906263 7734a224-1812-4259-a908-2d9e876b9e15 aad90b1a-85e1-464e-b533-1da765f5ab58 ef87977b-a58a-4732-b004-0078575a50df 7249a153-e81a-4d6d-bd6f-0cfd7059b2b6 af0de35c-3b56-48b0-8791-2a5f706a6a88 43d1ef80-7b40-47fc-aa51-8930100a5cc9 4ddc299b-9732-4a8d-9eae-1250e7ede54f 49cbe60c-4313-42c1-aa58-c422488ef432 50ab1906-5859-4109-8b82-fefd31173c74 5bf7d84d-946d-4616-96ef-469e3a6ca73d 2c12bc17-8be8-4033-a3fd-79ec2e2800f8 381c1d09-9a2e-4d4c-ac70-b271f86b4678 917e14b9-538d-4c98-8c1d-89fad1f51504 aac6eec6-604e-4fa8-8429-35998f162a92 acc64ceb-310d-4c26-bc52-8071a319aaaf 4a77b273-b56d-4dde-8cfd-f693bd845033 22d2b93d-9e8e-4c3a-9f8c-33cd00353612 2cb1e4ef-80ba-4cf5-a30f-cde86393cf60 0d6fa417-3ff0-4f09-a72e-99b2c48a12bb 46194ae1-4dc1-4692-a287-e3bc46831fde 70ab4072-ee04-4dc8-89ff-d03f59bdce1a 7d4f98df-7044-4bd7-bc8a-f9362e349e1e 8025ac60-a579-4c97-8da1-330ceba22e91 6df38c1a-4c0b-4dea-b7f8-8b2a3a36b4ad afeb5212-4648-4148-96b9-19105eb9e6f7 2fc5aa90-8624-4606-910e-c11a5b02b16f fbab00a7-c110-4709-88e5-30752fce8f2b 6d0f3962-7dd2-4430-8e50-749b866fe251 d8c06538-6abc-4cd3-9599-863b477d1d8b 86351b50-050f-43db-9319-01902ea0270d 65c6d64d-7d21-4273-a297-b9851b74f9e0 0ba42c67-0b01-4b73-9896-b366cd1da565 9bbb1bf8-6888-4bf8-bc45-66ec174eb2d7 e9d5a5da-ab46-4fb9-9a37-e481a5a550b1 1dcfe31e-a094-47a0-8315-da841e6027a5 5915ecdf-e92a-4f6e-991b-6383ed803019 e2ce2ea3-23f9-445a-ba2f-3b260d9e0542 05dc965c-bc63-43e3-a58c-baa86638dbaf e6badb08-c528-4a5b-8497-2084708b1bc9 a2e946b6-d733-45d4-a54c-00c74fc8971d d6103b3c-6400-45ae-a1df-b8fa5d598d01 1bd8d7b4-17d3-40d1-9ee4-4f6f7c2514f1 45764db3-8a83-4c2e-9daf-340134311b1a e87e5f76-bcd5-49c6-abf0-25ca19069106 45b61264-ef40-4643-b408-80a1b6d285dc 9082b029-1a5f-488c-95df-2ff7a33024c2 248d822c-2c68-402b-9698-b61aebbd88c8 503f3789-251b-43f3-aca6-4bd03cb6dbff 2135a401-e4c1-4f94-8336-d8eacc15fda7 d8169a22-06a3-4a44-88f3-86c9a3362c3b 0c0c82cf-c071-4f49-91bb-fa347c9e8a2d 863bc839-6f3e-4f0a-98a9-f3b58aa8d28e 25a6c38b-74bf-4789-83e2-cdbacbebf3f5 69f1181f-dd65-4b8e-9fc2-43d69367bf81 3d77e936-4d76-48b1-b7e5-f5e36972d692 083dddec-b698-4f31-bbcb-d2b9a493edd1 7c3d4a0f-103f-40f3-a050-d23ec42d4c79 2ca09662-61de-4447-8f7f-b02b19fe6483 d04a103b-b482-44cc-b7a2-8088b9114647 0409620c-de7e-4eaf-8694-53a034e64431 7a5fa258-90b8-4170-b6f9-68e9e44fab26 e1d6262a-399b-4032-9388-2dfa35894db6 c85e4e61-d394-4301-a907-71e6a37fd344 96706aef-8f32-44f6-a8d2-05c7cf3873f4 de988af0-99f3-456d-aa34-1a3d411e3726 44b47457-3ebd-41ff-b608-99d138d0986c f7a3659f-a609-43b6-a10c-ca4286794106 f6a7f6ee-86f6-4ba1-91dd-c2f2f50a4de9 545a0a10-2187-4898-bc6e-0b78e72de8c5 0e4909b3-e87d-4ee9-891e-f48354200eba 47d7d8d6-d10f-48b1-8970-dfbd57264a47 fb8f2731-31a2-46e4-b359-e1c2c4268234 fffe3014-6ebb-4167-922e-55cb9dc85625 b640fbdb-a2d5-4ec0-920e-940544c7732b 32d80735-a432-436c-8a4d-c8f1b907a6f3 9981c7a1-8399-4982-8d99-f0c647ec4934 07921726-db2b-460c-8d0f-da1e2d967b91 8dac6bbd-efbd-416b-8084-bfe9c70312d4 8a65d58b-0f86-49a0-8c86-1939aeed1a7b e032f9fe-3283-417d-8ca8-7a8e524284d1 42033992-1d42-4939-939f-a8cd2a06ef38 2f93bf3d-ba99-4ea1-a55f-f10779aac97f

## 3. Inputs and Contracts
Input: Profile metadata for Export-Bookmarks.
Output: Script execution status.

## 4. Execute
- Write Export-Bookmarks in export-chrome-profile.ps1.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "Export-Bookmarks"` or `bash -c "Export-Bookmarks"` depending on the environment. Expected output: success for BookmarksExport(PS1).

## 7. Done When
- [ ] Criterion 1: Export-Bookmarks is implemented.
- [ ] Criterion 2: Linter passes for file scripts/export-chrome-profile.ps1.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.

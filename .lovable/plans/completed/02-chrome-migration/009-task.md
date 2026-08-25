---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/export-chrome-profile.ps1]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section9"
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
  tests: "unit test-9"
  ci_cd_guard: "linter-scripts/check-powershell.ps1"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 009 — SQLite Check (PS1)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for SQLiteCheck(PS1).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Check for sqlite3.exe or System.Data.SQLite. Setup fallback. a2cc9ef5-0812-48ad-9ad1-b43710cb1777 d4eb3202-297b-4457-9f50-4f1f33828652 76817eac-4926-4b3f-8639-de59807804de 4d480216-f698-44af-bfc6-454ec3ae7b39 96ee87e2-6e9d-4d5d-903b-76363e64c90b 4f0367ec-66a2-4856-98e0-721d18ae5c01 58528843-1b7a-43cb-9ab8-b7db41e1f2d1 736d1181-10aa-49ad-8ff2-711e7e823578 fcff5e4b-65a9-421c-a17b-1828e602e219 62017df3-0bc6-4b8e-9474-16ef7e099d0c d2f3df86-e8fc-452e-80d0-9adaacbacd03 717bb807-8d69-45ac-bcf1-4596d7747695 69b22a62-7399-4874-9f34-a37a43366d66 595d8962-c529-4012-b35d-d513731634b1 fe0416d0-6603-45ee-a73c-5adbaf6e1787 d1ddc3d8-883f-4605-8550-55a095620b6b 5da3280c-b871-4e5c-a151-c5fc015319c9 7e66607f-62d2-48d6-8d7c-6810c42a0d39 14ad2afc-f3a3-4e0c-ad48-161aca33e80a 4ac0d976-eaf5-4afc-bc33-08d14bc5e0d4 d39fc6ec-ac57-47a4-8ef6-5e91d3b8c937 7de8a887-87b1-440e-91cb-3b527e16b809 7ddc1c57-9c33-47e1-838b-2839cfcdc3c6 f20f3a8b-c63b-4fab-887c-de33b0472eb6 b1ad8e47-4f7c-4990-84d4-5b392cb090e9 8b711e61-6c8c-4afe-85cc-f0a21aa06e7d d9172320-5df5-429d-82a1-87173b844d75 d38eb3fd-3a5d-4b73-93a6-1ca0a1ed0cab f479dc41-4298-40e6-b135-218521472f20 d0cc3827-0de6-4d33-b802-99f50d65c36d 4c097b72-bd0f-46dd-a7c5-449a55ee5604 74fa5d62-cb5f-4ce3-ae0a-0f8ce74dddad 1e4cb145-dd0d-42b6-9db4-a2bfda4edf14 287a166a-016b-44b3-b0d5-1fee99275f3b bed6dd7f-1c94-4df5-a39b-8d8e576de70f 3f0ad1d0-c2c5-48ad-962f-3adc39e614a0 4795aec3-07f5-4288-864e-380de562c176 7e8ec0ae-9a2f-4b10-8f58-a01b7179a850 c1e1cc80-fa04-46b4-aec5-ea1f9b50dec9 b3a8bc88-d1e9-40c7-ad49-ede00c3008bf 577158b3-57fd-47d3-98da-601d3f22d327 d6dc55e0-8eb7-4c0a-bf05-8e1209830f62 235bc33a-a58c-4490-a55b-280161c88e05 949dceda-bac1-490b-9149-034c0e757898 3d270a90-1464-4321-9b5f-c6114dc01517 535b3b2b-333a-4bc1-9a7d-f9d375599456 82f1e891-6c82-4a8a-bd5a-7443d1924e87 b43dd00f-fde1-489c-9ad0-aaf24d3bace9 245e583e-1227-447a-8a8d-dab7194566e4 e66ff474-7709-4275-a1e7-29ff5b77fa9c 3be76696-1c61-4b57-9016-c2467019f040 11b2fea7-d5fc-4a42-b9e9-bba7c0b05c5b 27b7a25f-dddd-4077-b01a-b924b52e3258 a7ffa6c2-44df-4cae-852a-fbf9a8560d86 30480b79-eb4f-49a8-8f09-0dcb3f686a7d 3b491e2f-d567-4640-bb91-6651cb9ee18b fc5a6b40-7afd-4f6a-8110-b2833fad5ed8 4ba4751b-8852-424e-8419-dff90ad6d7e1 d1a1eda0-66d3-4603-924e-4c523713d28d 57a6fbb0-90b3-4fc6-a906-99e6508311b3 85e8108d-e8a6-4bec-98a6-c8d47cae3c1c d6d52582-7263-4966-8fa8-134c7930a304 8b71fd89-9fe1-4542-abb4-1f0070515b32 afa27027-5ee7-468e-9181-3bbd598485b7 d52641f7-0636-471e-b21f-905c3849b399 5719ca27-f1d3-4bcb-885d-9810c22a040b 475944b9-aee6-4375-bd04-6d99a6188750 dcfb67e2-604f-40bf-8591-3e97cfd6c1b2 7a1d908b-11fc-40a5-8beb-003a3096d439 66ac7b3a-d228-457b-b0ea-98a353dc88e2 f73146f4-f92a-4000-8c61-fd8b9dc3e446 7dcd16b2-5a92-4284-ae12-e3c62b2995f5 9210e3a1-605b-4108-880c-4d4cb69ca0b6 53726edc-2bdc-437f-b4fc-ed9d941fe05f f70ff50d-36ac-40ce-8dbf-6537a6a21344 1e73fa09-1379-4c66-b9f7-12e4cf6daf45 9ab86240-ab4d-492d-9ef6-e42bdae3dbc8 d0327e2b-9d3f-47f9-acad-e9a4cb702624 5ed1fb37-aac9-40c5-a2b8-1835037e50f8 ba4127a8-c749-4a3b-8258-1eae914fdf50 c1dcc635-5c80-4414-abd1-4c60d088fe79 aba82068-df3d-4b55-8cb6-0c3cc3df1ee2 06af5931-1646-4800-988f-36e2abde7739 c4ec1a6d-99ff-4409-b7ea-de1b0a5b9ef0 293c85bf-e1a4-4f16-b776-1ca1e2aa3ccb 60aa0090-c7ed-42db-9d77-f42830ac7887 9aca97bb-5f4d-4abf-8caa-6b0dc64174b6 8e2b411f-3041-4708-bbb5-bf77eade8f7d 6918f0fe-c8ea-4c5c-87c4-d283bcb99870 b4cb607e-5de1-4356-9fe1-1b8b0ec47ce4 d0b01eb3-9e3a-4c62-8912-e6a0d1da6688 6acb2198-80c8-4908-a54b-bbfe1cd47917 454621e8-ff84-45ee-b6e5-b706b158a557 e9558e08-d9b7-4c9d-a694-4b222f35a5f4 09d545d8-b322-46e7-86d7-83f73dc42a37 6a5d05dc-911a-462b-b1bb-7204579ee538 9c602dc2-5ecb-4d6e-a914-003ca7f55514 cd78d75e-8983-455e-8fda-b5dd93b25daf 4746883a-1935-4c5d-8127-35f94158b6a5 64fde58d-89f4-4c65-8f9a-10c3eab3bb9b 4974c2bb-07e8-4e58-9e02-5eb13022463e ad1187b2-3859-4be2-bb25-eaaf244da5ec e878a38b-7e5e-40e9-bfc9-4820724008c4 fb96f0e8-8aa9-4b10-9148-022f3b3dea6d 3f7528e9-6647-4384-b40a-da3b0a828059 80a0e2f7-4dff-4fe6-9d7e-03dbac82d687 78207599-29d7-4b05-a6f1-d7870c817311 b70311a6-78b3-4247-a4de-9fad1d84ad72 95cabdbf-9955-4d5c-a28f-3ffa81d682f9 61bca266-2e86-471f-8c20-07b2b0c18e27 3effbf33-2578-43b5-ba83-9fef395422ee 20c3c0d8-e0ee-4e54-bda0-6dda1cace593 32387738-0d22-454b-aaa2-dc99cf84f5de 91d6bb36-b2a2-49cf-bdde-57ae2707317e f4bb9a7a-9fa9-4ba3-b45e-53368effc4da 79cf9230-6194-4bd1-a7c4-4b47d6b953ed 0bf0064a-9a40-4884-af10-4fe16fc7424d db509d0a-7a20-4412-9387-eaff90b0b0d7 ec349295-e417-4302-bec1-4f5508b04865 5864c955-9362-4680-821d-4ec58a31c5c7 7993b03d-966a-4f62-8e69-00b4d9f1ae9f dbe5395f-98e3-4574-b8b6-75476d2fbf38 4f0890f9-34c5-42c0-8834-8c4a0d0597bb 04f68199-68e5-4fa3-b3fe-4b4535138d74 7b1f8552-2226-4aaa-82b8-11ba29f61d05 860ac4aa-f081-41b6-930f-5f190bb0ac94 1f796915-f62b-415c-8f44-e60f72f59049 f1f768d1-fc01-4dca-ac6f-95618155eadb b3c0bf08-de22-4e07-aebb-c36b1cf162af 17e3b751-6371-4ef2-95be-6f60a1a54ec2 1c5ee07a-9fb3-4949-a646-3df9447a7d59 c2c070e4-b797-49a0-beb7-79b366b73bfe 0376098c-06d2-4c1f-b632-a8ecb193d0a8 aa600d26-2174-46a1-9d38-90c34f09293e b0dca46f-e118-4d21-8082-f60b3bf1383d efdbcb05-abdf-478b-a923-abcfe363c548 42868104-f12e-41cd-990c-553deb66963c f3c7b61b-d64f-42e0-a793-bf80eb556a26 812f8c8c-4974-4db4-84f8-1c65f63623aa 7550bda5-8225-4729-9632-8f0d7b48db8a 8d2aa4cf-ba6f-4e48-bdfd-111abaa53935 ccf0e2ae-f2e9-439c-8bee-4fe45cafb300 dc16af89-a3d7-43ed-962a-8445b7986cb0 c26dfdc3-06b7-45ba-a8c5-7b52e7e91271 357c6171-93db-412a-bf24-a12048a228fe d0d9b296-c71b-4227-8266-8f2353048f8b 2e1e91c9-5c7d-4267-9abf-dd7c5bbb04b5 62e3905d-a71a-4d55-889f-6772ac333e6f ff1aeabe-4608-49cc-a6f2-548cdfb36a56 2d6a6686-6b7f-4515-8215-a72defd2fce3 62e4f677-c41c-459e-b4ae-5065c1ef5196 6b368069-ba11-4c83-a46b-ad7ddcd7dc87 5def86c1-64c4-4eb3-8625-541cb76f172b 3b2b2361-5e67-4252-aaef-a9d7de8ad093 6ae8f17a-fb1f-4e4e-a091-8775ad2ab7a9 6f8d6c15-127c-4af8-ae9d-68e26513bfcd d4ebf719-47df-4d85-b826-23b8cd552bce 8a3c1d45-d3e8-4399-8ef6-9982f3174540 6d5904a2-a875-4bf1-a28e-23b371763348 1402ab53-9d68-41d8-b024-17d60ab43e0d 314b03d2-e58a-4e57-96bb-3a6bf21bc1a3 286f6551-6fab-4d38-a02d-46db66c55c9b 84c664c1-6ea5-4e47-9b79-2670b5169b8e c6e7c987-af72-4d60-bc96-4c234234f3a2 b4e874ac-330c-4bfb-abed-b16cfbaf45de 57bd0a93-2803-418a-be29-7b63c20986d8 5f5b7c4f-bc87-476b-9089-97dcf0e2409c 892aa118-2e3f-4b47-97dd-8a8e44a42820 14a215aa-0c03-4d80-887d-183f4b1b3c4f 430fa6f9-b331-4c54-8653-69db8e66f83a 64e346bd-431b-442c-ab19-9e2deeac6b28 edd41d9f-0337-4934-a4c2-c3851480f4f7 00fecc68-d8c6-45d6-b4ed-e7cfe2b4e13b c38d314a-a96a-463a-83e4-4d6394d81aaa a2737d11-47d8-41a2-8aa9-d87bc405d2a3 8c5863e3-ea0a-4fc9-9e8a-ecbfe7e2b6fa 0ed7ac7a-4221-455d-9ddd-24d87207d6dd 16fe0619-5680-4d9b-b98f-2d7d327dcb27 27e96b19-687b-4df2-80ca-8fa083b5103c 43bdce34-c1d3-4795-b72b-418dd7144dc3 1b28a557-a601-4e2a-8440-db931d4a094b dab386b0-119c-4810-81b1-c5e47f09fca1 3d752c55-4c84-4d1f-87bc-be1ccf2384b9 0b347f97-0063-4fa8-88e4-b47a75be50d1 de2b87b9-56df-4a4a-8097-57069bd0a20d 38c551c0-30fe-4d82-a78f-0a8a5c099cc6 67fcfb8e-3e51-41bb-a2e9-bc971ed1a4b7 625652aa-7293-4c97-be99-6aac291799c3 7823e547-3c47-4782-bd6f-797365050f2b fa4332cf-312a-4b30-a08f-b4f2c8e421ba 91f69185-551f-47de-bb79-08d9d6266da9 b1d26c04-67ca-45b2-8212-7116a6506dd0 2060e39f-5c03-46e8-9d97-9192d08538e0 f01023ec-56e9-4262-af3f-6ae0232e26e3 969a1cce-10fa-48ba-a924-7ebce0a9075e 7dba3a84-8413-4dac-a9a0-7b471218d5ed e51cce0b-a55e-43fd-8fb4-0381533142f0 47616840-9d47-45f0-a1ec-975c4abea9e1 e64c3fae-b858-4595-8952-2de7a7ca2bc9 6e29fc46-e7b2-41b8-8520-5cf2b93c61b4 fc6320c6-ff50-4c25-84b8-4d43bb1595ba 79e6eea3-795f-4e0e-95b7-ea9dab2b8c0e bf432f4e-87c7-479f-8569-f1e3593c6f0f 39e849c2-8d1a-4d6b-8746-e19732470ef5 efcada4d-8cff-4c8f-a06d-4c1854a212fa 0a4c5b0d-ea97-4bc5-b115-31964d188e62 583b07e2-4a96-4584-83d3-0e64b12d2fb8 f022d723-f507-452e-9d2d-d594f9ec3f26 f8cf04c9-7e81-47d0-8c78-47492a461108 a4cc63de-8243-434b-ac84-0d2f64288a17 b0a01b3f-7aa9-49cd-a460-9c52c17c86d3 e29a1390-9f7f-437a-b36e-57f408afeddd fe42970d-bf25-41ac-b59e-2124f5e1cec4 30f2c5c0-8f55-4b41-b5a6-e08dca2609ce e2830d53-bfaa-4906-9d9a-c349acb31ef2 b12b7fa1-b8a4-4ca8-97ab-c97647ba855a 52a636f5-1a70-4abe-a957-81e307765f85 83387401-8d81-4fd1-8fc9-3b3ce584153a c7957e9d-015c-43a9-b485-9fc3f5c2debd 68a54756-80cc-405b-a6f7-9a66c46205ef 68580d20-b1a7-4742-adc1-28e116798c7d fc708326-946e-46f1-97ea-e9505034a9d1 7422eca3-cc3c-4676-af70-d897fd0070de bb8ec07f-8927-49c9-8542-f3b0fcb38afd b1156733-c641-4d00-b43c-cf3943f0524a e1a9f1e1-58d6-4807-b1d6-7893feb91917 52de29a5-87ab-489b-8765-8b85deee4683 f9a6af79-1bb9-4fc7-923e-078b605b06dd 930ed1cb-435e-477c-b76d-54ab8ef988b6 be1c0881-6399-43e3-8af8-2587893d1316 68064d2a-6079-4d4f-a4b9-6132b6a22eba 15d0391b-6bb4-4400-94b3-6187bda9d54b 23a8ccae-1d47-4054-94ac-0d5d6b8db651 a977ae08-e543-4295-8e40-d796879072bd 6fc7f644-b79f-411e-aee7-59e42f2cfea8 f60b5d6b-6e4c-432e-8de1-3ffc23ae8997 606bd8f6-e454-476c-ae64-19414987a476 3f4fa058-f11f-4bc0-8396-bf146eabfede 35e0c112-33ae-42bf-99e9-899815e481d4 c2514a95-d855-491c-96fd-583c49681629 eea7ae30-d503-4909-89e9-53b10ca846aa 10f38ad2-f7b6-4902-b909-408be8e6e002 aa17c8d9-2736-4724-a4ac-2ea1625acd3e cf00e9ee-7389-4adc-ac89-9ffa81b34daf b0aae7a3-b035-454c-a98b-7c7e6fe8f9ce 0d4e4b6f-a626-43d2-ab73-29a410fb666a 82d75a95-40ae-48de-bcfa-8a41f883a731 233272ea-0f2b-4e82-9c32-ba9bcb77da13 fe0d6cd2-f6ad-42f0-b244-c6fa39285891 e60ec599-006e-4df6-9fb1-7b4c14ffa164

## 3. Inputs and Contracts
Input: Profile metadata for Get-SqliteExecutor.
Output: Script execution status.

## 4. Execute
- Write Get-SqliteExecutor in export-chrome-profile.ps1.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "Get-SqliteExecutor"` or `bash -c "Get-SqliteExecutor"` depending on the environment. Expected output: success for SQLiteCheck(PS1).

## 7. Done When
- [ ] Criterion 1: Get-SqliteExecutor is implemented.
- [ ] Criterion 2: Linter passes for file scripts/export-chrome-profile.ps1.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.

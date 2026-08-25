---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/export-chrome-profile.ps1]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section8"
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
  tests: "unit test-8"
  ci_cd_guard: "linter-scripts/check-powershell.ps1"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 008 — Preferences Export Settings (PS1)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for PreferencesExportSettings(PS1).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Extract download, intl, spellcheck, profile.content_settings.exceptions. fffaa331-3793-41b9-8fa7-ec14227e02c8 e32cdd21-6fdf-46fe-8460-069087c7b002 94312a8f-aa7b-46d5-8424-aac6c5e722a3 8d6e71aa-8bee-42b3-9a28-d3fd85f3722e e456c8fc-1599-4a13-ae28-c597f4dea0b9 b064bb86-8b63-4c71-b9da-b4e9e28d7563 743e05e1-d6ec-4469-8123-125596cc4c9d afc84786-a0c7-49e5-a54c-df873649e8ca 713e538e-0039-4e38-89c0-8fb6cb1fbdad b1e1faff-053c-4824-80d8-bcf303153f18 844437c3-cee4-4c0f-9375-50a6ff505b6f 2afcdba7-5373-47d2-a478-81b98b449188 989bae8e-4dd1-437a-b468-cc61992f5ec9 8829d70e-bb1b-42ad-8991-ff5dbdf2892f 576021b2-eb89-40d1-8fd4-826662db6804 09768c7f-3a59-4d48-9620-ffede425eb20 d36a693c-09fb-41d7-a581-1c1e6ceaf9e5 0b8bd11e-3e3a-43cf-9a5f-b165b24ea68f 48283971-7724-48b0-9a6f-3aace81db483 d2688b3f-a124-4e35-bb70-6948ca1baf80 8fbb7b2e-b2c2-4c1a-b513-a79d85384eda 9a424d2b-e493-4b2a-a778-0140f2a79536 43e70650-c03a-44d3-ab81-28ed0320dfc6 6a2e0ae1-0109-479c-bab9-a481ea738425 9c348cbe-d8ee-4914-be67-b6042b046b1c 1874eaaa-4447-4c24-9d64-a4ccf81a34a2 bb6077d4-e51a-4b4e-b802-2c915a9a0917 fd3030e7-99db-4b5d-8a3c-674b96e32c47 11548317-677d-416f-850c-18096e0a0be7 4762464d-dc04-4c54-b39e-2c9f44372e91 54344932-937f-458c-94dd-af9f1db74003 80cfc97b-a9a6-4011-9929-7ee69006c03a 203a35b6-a1a6-47fe-8872-98bfd73f03a4 7aab1554-c549-4333-9e34-a5159e9c285f b1bc6e07-532d-418e-9de0-07b43b77b7ff 426773f5-1d0b-40ee-aa83-17c96b9e84d0 ed0dad36-e6f7-4391-b7e4-1cce5ffe1d04 117c4624-47de-464f-9673-feb1bd6aca94 e44b1cbc-a1b4-4ae9-8eee-104160b89154 0fd74f15-e0bd-43fe-8038-b3c2052acf32 029bee91-cffd-4176-bbde-479abd22f24e 01138ebe-4746-41b5-bbfa-fe7cdd2720f0 23e95762-7b1f-4a97-a5fe-33b6465f4214 343356c0-7989-471f-9673-007027eb4e06 68fcfc2a-0423-4c8c-a2b7-960a7b1cdb1c b605fa05-14a7-499b-8c10-5faa56e6b8fe 70a26996-f666-41d5-ad2d-34ca0b4836e4 5d030c7e-4f22-449e-bbe5-ee58a0e1a1e7 8bf4a0a2-6fce-47dc-afd5-f6f8109195b7 c07f8562-3269-44dc-b70e-375acd54f52b a1aa4f07-903c-4994-9ff1-99b7314cb412 8cbb3034-694f-4164-9a5c-191e20eac245 2dc7485e-5e15-4ed8-8852-b20095d37041 fe05ffe0-387c-461b-a654-828460cfc1de ac71587b-71d6-433b-81d7-46b0caf1607f dfb6b2e9-dece-4557-8009-a29955bea6ec fa40812f-97df-428b-93f7-c8fa89956b57 bd78e754-e46e-4ba9-b9b1-f0abc6cf5abd 0230d6b1-db1f-4b13-ac2a-f2243a3015b1 706ec1a3-5a61-4d48-b2a3-1e1d938dd7d9 41151c4e-7ad4-41d2-8a1b-780b079a644a d9cd47d7-9454-40ce-9aae-2e7ff7f3391a 89570201-fc10-4045-b683-22f5e310cf74 0e026df7-1cde-4b73-a15d-2678df7ff5ba 58002fe3-9d8a-4d1c-99ef-0edd17ab5ac4 eeb458e3-16ed-436e-a87f-29884d28787a 23efa0de-d87f-4b21-b5c6-094daccce428 d4166029-7f32-49bf-a28b-015ebe50588f b393c5e1-c34a-45f3-96b8-5822dad48259 e7a29b6c-bd2c-4ef6-a71b-124a7bdbe3ea b0443e78-85d8-476a-a7cf-97a261eb4182 3d1b0854-af80-459b-a292-95d3a04730e3 a4580408-0b72-4e59-88d9-f6e2e45b041c 60e90e3b-6637-4a92-a77b-102d3c612c2b a94ca648-8aec-44f2-8db6-27818922b311 0691ed99-d490-4234-9340-dfd357a0231c 768a23b6-b653-4ac3-8aad-9b4d35b53902 e0354cc9-20cc-4f67-9d02-00a00b100a31 5d3a1f1c-4ec3-45c7-a2ca-623609278df4 e831a8d7-e585-4d8d-9112-6468d69e1179 2673247c-2990-4e03-b278-cb79591cc822 9820262a-2eff-4a12-b518-fdec4af537ca 069fa0bd-e0db-42e8-8446-d145f06a6a0e 7f9db868-cf97-4125-a6a1-4cb8e3ab3cb2 c8a7eccd-9897-44be-9df0-419750bf8226 9c6a1d11-b90c-4b6a-a94e-b9fbe7ef1e58 4b828ac2-de5b-46b1-aa66-a7b30ac96ab6 f4e35a4a-b737-4638-afa8-e6d5ff85b48f ff538fba-154c-42f7-b47e-c09434af7f10 547c86cc-052e-49db-ab81-7f88f3756cfa bf7cfc3f-cf4d-46fa-b1ed-a69377b102df 69db8656-65f8-4b19-8a28-e019e6a652b3 c67e1d74-09d7-4882-b4b9-e3b1203f0d8f 75205b23-a215-4f2e-a99f-2ce10ae13238 4aed08ff-0aba-406d-aa6f-812dbf0f6591 ee96e4f4-faca-42b9-a6c9-ebf8e0b84a71 da802763-8b44-41e3-9425-d29cd11ea9c6 88022c3f-3854-4b76-a3d7-5d02850ec1f9 9050ac35-7d43-4f96-87e2-1ca80bf0d45f 8e9f8015-1cf3-4a5b-b0a4-82a3be87d708 e2017f57-447c-4f3d-9f87-70c6b5b3efc5 3f1f6740-2de5-44e1-8d64-0aa84a5f9237 a808606f-53a9-4eb1-bbfa-8e0cfd1f2c8d 02b92577-0031-4c4c-a311-1da671fc272d 8d8da05e-e6c5-4420-9ae6-ea70e7cfbc0f e4293348-bae2-4b7a-a4e5-440e922d4ae7 73425382-0d0c-4e94-aa5d-3ef50b947a78 ac98d962-2c98-471f-be2c-9fe8b3e4a7aa 5cad6219-b714-4eb2-9759-40f956b977c2 4c1cc179-ac10-45a4-881a-de601096964b 3d1c534c-7811-40f6-8cbf-4e38c8421950 cebba914-135b-4b7e-997b-1cb0dbfb0f46 a8501f9b-4648-46b3-99ff-415105ac3843 fd0cfce6-5f9f-46ff-8c4e-acdcbaa4b01d 4cd7de72-d0ba-474a-84ba-efd2bbda1577 7d812211-c5ac-415a-8a8a-7a53d1e6b8a7 aa4042e3-c4b3-49a4-a909-a970524227aa 9d6e29f4-3547-4cd8-8a61-f570e31ce435 3ba3c2f4-de87-4fe8-8f4b-3da7e6026c38 a63595e3-a50c-4bc6-88fa-bf35f01b33b4 e88c6808-4a3a-4f88-93b1-fd11c0b7bd7a b13ca3ee-1ffe-4c0e-8f3a-377ee65f7bd5 3dcb1e26-d2d5-4719-a1f0-cf60711b1c80 37000f6a-e948-41f2-b0e5-0a6fde6c71df 21cc2337-4fa9-43ba-b700-4e7fb1721159 df2b2bda-95ad-4f48-b5bd-fef61ee536f8 df9aa5d5-460f-4d0f-bcc6-2bfb971dfbef 16c2389b-0f5b-4aac-9338-48e4555197c2 7773dcd2-9697-4fa9-8e82-181a4a66cf20 2b01ac20-fc47-4479-94f6-cdbebcf487c0 c4a057f7-858f-4ac3-bfb9-9e3246dd058f 3c143147-c9bb-4377-af80-1d3e14ed9576 d8bd4d56-dc2e-48b6-9fc6-8db84147c7c9 b8aa0183-ff32-43ae-96e9-be28b76bcef6 0fa4e77c-f6c5-49e2-8b7e-fc70c0a2cfa0 28144994-cf03-46ac-939b-d62a654ec24d 9268ba47-7171-4fca-856e-78e75fde65c7 66421b09-ef55-40e1-93d0-582917297ad8 2899e57a-d99c-4676-8cbb-2dbd7af76f1b aca8d235-f57d-442a-af31-894874d21dd6 3a94e8f1-a988-4a02-a886-546deb70b832 55058af9-64d4-40bd-aa2b-c491435fe00d c12037fe-5a12-46d7-86ae-48f56a88b3a1 162a9ab7-4b25-41f2-ae63-f37fe7505647 21f752a0-7bde-439f-b412-1abe9f20bd3a 8bb87709-1127-4b9b-b5a3-091bf5fc85d8 ff82f6db-bd6f-48bd-a4de-da6c39d26174 cb4a2270-d65f-4164-ab93-5c5a17a3ed5a f01b85e0-c833-476b-901a-61be52aeb9b7 4223a3a3-c3a1-44dc-8825-065965b3cf55 1882a8a7-85b3-4f1f-a0af-d745ce7828ac 921c78bf-0eef-4cee-aa75-ff1760d8dbe2 69dc79a6-838e-45ff-96be-eb8ae58754ff c8b8a5a1-78dd-4930-84a1-36dd7d8204af 55d31a5d-c5fd-43b9-94f6-2d353032d80a 593b134a-0d71-40fc-8718-dc9ccac99b59 08fa5f0d-6ee2-49ec-92a7-53063a7e88ec d2cbb347-a694-4f95-bee9-ca1783ae04fa b3ec13c8-4ddf-42ae-b829-a5f29b8e99c6 3420119e-425b-494a-bf3e-990278640cf7 153a095d-a38c-4e05-abe8-b7b8760d97c4 14d6a55e-5122-4465-8281-5845dea36195 ab2ef1cb-5728-4ebd-b0c8-56fcdc67d5d3 891b7b50-d4b7-4d79-8168-09042f248d18 6c63b613-82a7-40ac-a65b-e151d99349ab 7bdd4063-6d21-4ffb-b39e-0d3bd3efa48f 190b16cc-be8e-4eb7-918f-62622ed54700 6b7e939b-56ae-431c-b3be-c37591a8d4aa cb84fbd5-ca2a-409d-9aa4-4ea441cbbe67 2b370dd0-59f8-4dc0-a736-fda373ea49f7 a7c63962-4c84-4f16-a3c7-785cd345bce5 637246da-7ef8-4f2a-9999-e9b3a4121388 ac495e67-887d-471b-88dc-0ff3c2f1758f 6bcc4b4b-3bfb-4034-ae3f-a8282fdd3c62 3ab0f6b5-a865-41aa-b118-8477d324d0e0 ffbfb936-6a62-4d4c-afa3-a7403dbbbebc 8204b48f-d52d-4ff9-ae13-40d1f9b653c1 ff2ae56c-a38a-4750-ad93-24c489e129bf 99cc1944-d078-46ac-ae3c-3000d5a1eacd 28a2e8cd-45bb-4ed6-99b9-a6cc5fad0b9a 6825593d-c7c1-4fc0-8ca8-5e64390b7e0c 22fac166-e1a9-4ff0-bf6c-905139b0dd3a 60d4b8c3-5b2a-4001-a793-bc52d9a5307d b306fb57-e6ec-495c-8fd7-48e722143401 459bcc74-0b9d-4458-9c58-cb5f4f1e52ac 566674b0-5a98-47a6-a699-a7cfc16fd244 ffa4502b-df63-43c4-b69a-316c1c9d3dbe 08f75b96-3c55-4338-a8e6-d90c82ab56f1 84248476-083d-496b-b732-21c6dbdfcccb 44740e11-4604-4e4d-a345-530f2b576d8f 28828f08-2908-49dc-a522-87acb8a4be55 ffb35774-ec1d-449b-aebd-943ee1d0c46e f6fed758-eb0f-448d-a3bd-ad7fb72779f4 a52db663-1d1f-46f7-8609-5696ce0c075d 5983a410-c8db-44ec-b5be-cc0e1d29a569 b4293400-894a-4012-ab27-d8ffa13b0005 8e7a9f99-f782-4681-83dd-93d58948762d 50650da6-bfb7-48e7-ac26-3ea75a30211b 7919be56-05c2-4df7-afad-88c6ee81d772 6cb5565c-11db-4bc8-b395-e8d02af26b08 1228cc87-a399-4bbc-9d4c-c82e05a37069 d86e853e-d792-4c09-a930-6ba6a63b5d74 a1eab2ef-46cf-40cd-af42-b762b27dac92 476c546a-7de7-47e9-b6b7-cb93c99b6f22 cf933d21-6fbc-4be2-acb9-972cbcaaac68 2309b0b8-73eb-4991-bfda-39a33f959a63 8fc2dcb3-29c7-4575-b4a2-65b1110f67b5 5df214e0-8a41-4f39-9a41-1fef6bb45b2f 70ba212a-f03f-48b4-9313-245091ec3570 56e1822d-2c3d-460a-86b8-31862bf47206 c008f8d8-4983-4234-be8d-2e8f0cc23ecd 3c705dc5-bd3f-4cda-843b-50a4c2a3ecaa e4b97522-412e-4a05-98cc-e2f8b98468e8 200ac66f-035a-45a8-a676-4905149c9140 f6db7605-57c4-4a70-bd21-42359485995c 578784f0-5a96-488b-bc92-94573aae65c2 e6e45c00-03bc-4adb-9e70-f215c6e0a2c3 a25e55e0-b4f6-4933-8ea0-5d5bbc20193d f4013c9a-eede-450d-97b7-21dc51524024 48120601-5c46-4b3f-9d1c-10733df09523 25900e46-bf41-460b-91d4-90aeb13e7e8e b14466cc-54f9-4c6d-95b6-1effdc88088f 766c2578-acb0-4796-aaef-695e6ce6571d 90e11898-2393-4520-aa6d-fc7f6d9a3ea1 6588c0b0-2f6e-45fd-9c9e-0d6ed16922cf e5d84909-8531-41a7-934e-15939e5917df 4db19cae-7e68-47e1-86be-ed933c5e8ea9 5603c331-7dd6-4bc9-89d1-959159e4e378 7344d6ae-5e31-463d-ad8c-2da63298b41c 5285ebf5-f84c-4b07-8c17-ea9ea421b966 38c77c77-cf4d-4793-a0c7-ae29f392855e 1bf453b6-a20b-4112-b820-fa6349446306 63dde2cb-b692-4151-a3ef-54375ebfafd6 6cf3e760-f474-4fb3-b685-ed2f5bb60d61 0651703b-77ca-4f8c-b52b-1090e6921923 ee1c70b3-cafd-4274-91e6-97b59464f6c4 9faab642-e112-47f0-90ca-1c20004a9e6e 5f39bccc-8669-4da1-9893-70e2fb8d53ce d15491ae-b6b0-47cc-8b10-d3d6ccaca56f 25c57547-fffe-472b-b14f-57bdd3e261ef 0f8c6981-651b-47fc-bc9e-db5baf5b55f2 b9d30d88-35c4-441f-8b70-a1557f83c8e4 e9534512-c6e9-4427-a12d-45a11658635d a69c817d-1f3e-4c76-98a7-94be8d1835bf 6daafd75-dd18-486d-a0e8-e9f80b7fb47e 9d6ea810-9dcc-4dfc-b685-20471b910f46 11541f19-534d-4d61-8c63-bf57f347eed1 b838a9a5-9ae8-406b-8334-1467e5d71ae7 7ccedb10-b532-41fe-8502-d855894a77c3 f3096de4-a6ef-41eb-8bf4-5b71a19fc086

## 3. Inputs and Contracts
Input: Profile metadata for Export-SettingsPreferences.
Output: Script execution status.

## 4. Execute
- Write Export-SettingsPreferences in export-chrome-profile.ps1.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "Export-SettingsPreferences"` or `bash -c "Export-SettingsPreferences"` depending on the environment. Expected output: success for PreferencesExportSettings(PS1).

## 7. Done When
- [ ] Criterion 1: Export-SettingsPreferences is implemented.
- [ ] Criterion 2: Linter passes for file scripts/export-chrome-profile.ps1.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.

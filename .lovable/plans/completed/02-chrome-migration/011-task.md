---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/export-chrome-profile.ps1]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section11"
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
  tests: "unit test-11"
  ci_cd_guard: "linter-scripts/check-powershell.ps1"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 011 — Search Engines Export (PS1)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for SearchEnginesExport(PS1).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Query keywords table for search engines. 8b909014-5eab-4023-8d73-5f52667b477f 3a61dcd3-6ddf-4fcd-914a-394563ced155 cdec5b81-e78f-4613-9771-e5576ef5b14a 5b7a9f48-3be9-453e-8922-574fd5622381 e114b32e-28e7-4cb7-88d8-1a35bca72fc2 f06a7c31-fa8f-4b90-8cf7-e8ba5528f86d 8cf2eac2-7d18-481d-af89-9801f1b5a482 8ff64bfc-c6f9-4ed0-84c0-faee614b81f5 d608f604-d638-4e70-b1fe-31bb68d5e259 523151f6-2a8e-46f4-abb8-bfbfe89b0920 4699817d-2940-4660-a865-46c9aaaf191c 2d9dc571-2d97-4b8c-8601-661d7b26780d c5ce245c-80f7-4a03-ba1c-3158c93f2844 b316b8a2-4fa0-43d9-b676-64ad38ae5bcc 39bcd5c2-2b1c-4ed1-8ba5-8f2e53101064 d9b6b5c4-be00-46d9-96fd-36c3325df5d5 06a39e8f-1656-4161-b8f5-d410f0c833b5 91027651-c6e7-4882-9850-97c899d0fd6b b70704a1-a9ca-4480-ae29-3c3b717283c0 3fcf0ade-9f15-4167-affe-12c0988d429e e91f4d89-1ecd-4bc0-8477-c30aaeabfb51 d87dd383-2ca6-4483-ab32-6a2116f4b551 c145e936-0751-433d-bf76-aef219f62455 ad68b3ed-a304-4070-8658-ff12657d7426 1602012c-d971-463e-b943-14902d6906d7 a93821aa-6122-4233-aeb6-a13c9b18897b 7aa9c66d-dd50-4ab7-b55b-425776c599ca 6f9814b5-f56b-4f1e-a07e-b28c0c1a6384 65929187-c4c1-4155-9ef7-0ee67fade509 feab1737-4d02-46ba-9e32-76661f3fb288 a125f4dc-e3b4-4a79-bd24-c941acfee41c 85284639-f6de-4f6c-80b4-2346fc0b4873 d4ca61be-8012-476f-ac7a-a95893fc983e fc4018bd-ccb1-4583-8f58-e42bc3db095f c16e7cf6-5a5d-4899-9385-5b811e25d3e0 b837b56e-3f33-478d-868f-ca20f5a4caae ab17dc93-0efa-4291-a210-cea24a56825b 05dafde9-723f-4857-909a-6f051167aa18 09b6e396-1eb8-458c-93d5-fc01c865e663 2b1cec45-948e-456c-b7dc-1da1221fbf03 b4bedffe-7b49-4b95-9fcc-8c66f8277950 d3addd94-7853-49eb-aad7-a53e770d85b7 ae8b327e-e120-4e41-b34e-f09abd7f685e 79bd4144-1eb4-4d8e-b013-fbacedd5fc9c c348cd4e-c905-4e50-8e3c-d7e066b6c4f6 62e7106c-fbea-424a-9fd9-dfde66501c06 ff431257-cc88-4943-8304-9cd5161b03a4 df20d732-1469-4b64-b6dc-dd339c1de8a0 d2537812-2b95-4fdd-ba59-befc1187b8d6 cfee407a-91e6-4d7e-96ce-979add6facd0 bd077fb1-af92-41f7-8b20-4ae1f14f45de e7e1e645-20ab-4e14-b5d9-4c1944ca467c 0196f345-4a0f-4262-ab31-604c355151f7 4543d822-da7a-47cf-b06c-05107bc754d7 4f9ce0f3-56f5-477f-b4e0-0e90fab78989 7c52065a-3c63-408d-9c80-0c4aef4e080f fb52cf28-b00d-4b8d-8966-9aaf52de4e04 5f3b4ed3-2b03-4ad1-bec5-942b46a63bbb 3d7b12d6-166f-4276-b39a-9aa7ce75a769 a1c79fd5-a4bb-4afb-b1d8-dba62cbcf312 cbc31d7e-caf1-4b4f-a626-44bbb1571d96 08f61a4e-f45f-4f1e-b694-f85b0fb8fe93 36df78c5-f61d-40ff-a967-923f2c1bc71c f89acf5d-88bf-4502-96ae-2fdd5f5bd72f 681f4b81-fc5c-4d76-9bb2-b5e06da273d7 5632e2f7-a423-4fe0-9b02-1cd007588887 7c1b3e71-0bcc-4b32-b3f2-7a81585d66c4 f2a9869f-9e22-47a9-99a3-3144b2677c9f a08c11af-3ebb-4335-88e6-8820383847ea da1425ba-be54-4cc8-b963-c42219e4572d 6ea8b150-28ff-4d25-8094-170b35770408 f7c0857a-2ccf-4c9f-9c69-9ecf5252d4f5 d89989b4-23c3-4796-9bc1-912e8bf934c4 ec1cdadc-bc75-4e44-9a8b-07f65434544f 885508c7-3681-4d70-8e75-8649e4b542b7 0b5d43b3-b819-48f3-87c6-5457ab40aed5 9dad82af-0e15-4d61-8033-a6776be2d2bf 91ec36c1-b223-4040-9995-66f1ed6c7aa6 348a117b-ad0f-4c9f-8c5e-3401f92fdcae a60beee0-55c9-4e37-a43c-0e1c8ec40a15 4255452a-59fc-4c9b-95b9-08a960c51c90 6c3e88c3-536e-4c94-89ab-6e32d1f745ad 298669b7-6b94-4017-b800-106827a65c3a 0fb3ea7a-537a-47cf-930e-d353659cafa1 cea15559-8af4-41a7-943f-8b077223401d e66d9f25-cf21-46c2-a83d-bd39de7ebf1c 9b5bf70b-f748-40e3-898c-e37381017ffe 87319a16-98be-4639-9255-ec29ca31aab0 f7a3ce31-9860-4b87-bc5e-c1d922c35478 5c109a32-3a00-43aa-baff-385cc7846a29 b1399296-ebe8-4d82-b436-9f868b3d9ffd e90cdf48-28df-473d-9631-d1a2296807c7 ccb49f70-7a8c-47a1-a3f1-7f1bcad49e40 21e8706d-abc4-4e12-8b7f-01bf79fc0086 5465c07a-74f9-401f-b3c4-8c61a189636b 59170c67-53fe-4faf-a7f7-c061d066c548 324cdfa3-7b25-4056-8632-7ce29a86a409 8b0d571e-5bf0-4f5b-8179-266bd88f98a5 28ba9c91-60fd-409f-9fc7-56260b0f3329 981d8d4a-66e2-4b6c-85d5-532fe6ac67d1 22447b7d-b646-43e3-bd54-6947b3c5b095 3867ce1d-f510-4494-8c47-638434ccaa70 579c66fc-5bed-4e74-b9cd-e7a40491738e 976936b0-5c63-4c40-ae88-223438f2cfc9 2ab242cd-d8a4-4755-8304-261187b5133e b9445a93-77a5-4cff-ab49-d1db8337feb9 a23716dc-f11f-4f79-94d1-1e8daa98b7f5 5c6d22c8-ce85-4c90-992c-e1fc79207d3f 3691f017-37c6-4e4a-be01-d32871b01708 5e798b25-02ee-4d77-9b5a-bd906aeeb6fb 8588bf6e-4d68-4e3a-833d-6bc83f271e45 2c6f8316-167f-4307-8661-735d2ceec911 e561160a-8807-4c0a-a2d9-6d81f4de4854 eb015ca9-6ee6-4e29-966d-8f80f866b357 28fabf74-c4e1-4174-b12d-d2f3c050e7b7 cef3dbb5-6e07-461d-9667-e26b1273ec3c 65b1b67e-6343-4e1c-a618-8b406adee1dd 44ff4318-babd-4f24-9c0f-d0b044e70317 e213da6b-df98-4e58-b07c-b15d4e592d72 72ac9832-6ae9-4479-822f-84485e976feb f54c1b28-85f3-43ae-b117-fcff60b9016b 6deed42c-8f90-44ca-849d-5be59c049629 7e3fc081-7bd0-460c-8914-d8d5ca5c62da 9c19209f-4215-4577-a2e7-15a7609b1b10 c275749c-fa11-49e2-b065-02d6738dd7ce e400764d-4a34-4645-96d5-d811e7943951 7cbdc9d4-8279-4573-ba2c-d7d67e5a10f3 28381f8e-3d22-4c0d-aa34-722480a01645 b3cff6bd-27a3-4e54-9b1b-6d99d0686ed9 7b2a3a26-49be-4991-ab4b-ebea9f73179b c48207c6-5584-4c5d-b2fa-a50a0e85a18b e745a138-7040-417c-9b9d-b3edddbe70d9 408120c3-1e66-4eee-8c95-2612600e3f02 3c2e7fca-639d-4360-bd2b-451d1950ffa2 a18c271d-1dec-44ce-b15b-4540c6863164 4effd87a-b6ea-4c4a-a167-3c1e77671ee7 d9b36611-cd6d-47c7-b8df-7853450d7187 772dfa12-1bc3-4be2-8fb8-66079ecdb1d6 f4d2378a-3ea9-42a9-86f5-bd0d27dba7fa 43d05a89-046a-4d75-86f5-6a7e9321c8c2 f72325ab-ab84-4f00-807c-4b26f58e97dc f4f599ad-1215-4ed4-ad04-ff2134dd01fa 3ea7cae6-fda0-4e98-a05f-7b5bf729fc5d 1949e2a0-b66a-4273-a9e7-4c8e748f5d95 e5a4ca9b-8b4f-44fd-8379-13cb1939b0e7 c6ced4c8-5412-476d-925d-ea7e9db68a0f 3f7e2342-9830-43bb-99b1-b49d2014b052 2fc1f84c-8536-4c76-8803-c009e45a352e b41810fe-e7c5-4792-a5d6-eb5632aa8d3f 2f54cbf1-c157-4597-9c08-75f422fce28e facd0edb-53a7-4ed5-b4c3-35c81c980aa1 d561812f-31f1-4e00-a564-a4dc15ac7216 1149c3cc-5188-4780-b5a4-08ef67be03a3 a455b84c-7780-4d66-acd4-4e30d5fc7492 f1db9bd4-c6f4-4ceb-b439-c66544d8be15 64ab6af9-cdc0-4943-a4fa-5b6abcd213b9 5c27b807-1cd1-4160-9aeb-cdccf76895cf 3b80ed13-e777-4e6c-9ccd-968dd2eb6c20 4e98c6f1-595c-42ef-9785-cf1e524fe05c 1b0ccae3-019f-49cd-8995-d3583d0d6e6a b74164a7-b5da-4ce2-a1ec-daee988f9ab4 48b3d073-ea43-46a1-bed5-17d4f7ef22da 03449300-cf16-4a42-9586-ff1fe9300053 c454bea3-e89e-4d1a-90eb-0a69537b1e80 91cfd645-d024-46ab-8a39-e1926263801c 97c8a872-ba2d-4027-aac6-f06dd0a4cfdb 3d399f6a-488e-4973-896f-ed194d78ce65 fc10aa48-fb17-483c-be2a-30d2611efc76 d154df27-1e22-48d8-8107-783d1f9fe049 29e21af2-b40c-4dc5-bfa3-b20732ae0e9a bfff84d3-d050-42dd-9028-4c6187179778 ba3a6bcd-e113-4bae-a67a-a5ee1426d564 1dcf43bc-56d8-493a-a6d9-d265233bb0c3 b1029bdd-fffa-4834-a5d9-bd411e00eab7 91ab492f-2d5c-42d4-8069-8d26de462813 77511d23-2637-49d7-9e45-e178eab60065 5321e080-03b1-445e-a38f-29b35cdddf56 a393e46d-088b-4447-abe2-32c118884e99 edbb2c37-3b20-4cb3-bf11-91786dbbb9ce c29ac3be-770c-4ebe-8b1e-a0c4df89bb35 a8ff3b49-29c6-4e28-b878-c5f2516748e6 c3ec4af0-982b-4b95-a7f8-a42f75265104 13f898db-29ba-4847-8ef2-393122ae3586 6eb711bf-a242-4e46-ae99-b272a254cbdc 1d47950e-2ef8-4faa-9e7b-216549b3599c af502fd4-e04b-43c1-9d2d-59af24210d7e 32add14e-3437-442b-9ee6-ab430af5f13d 2bdb22d7-cd7d-411b-a164-c862e3bd8fdf 72a4cadc-3d86-40af-8524-b32e9bcb1c8c a35980dc-6b04-4889-9a4b-570a892f30b2 e0b6cb7d-c40d-49e0-bd08-160eef7bfb38 49660eac-b4af-4ede-b3fc-4517e2b4c042 d00c09bb-ab6c-4955-8bf0-fa461ea00c67 1a6488be-66ad-4c7e-8448-81f808b34d0d e12f72dd-a65f-487d-9856-50b2a9a118a9 1ffa6786-7f9d-4110-9eb7-4023545db06f 0651c939-cad6-4dff-9550-673bd632db8b c42367ad-3249-4418-ac56-a2c9391b6f76 6868b59a-a0d3-4923-8a03-78bf3e5f3365 6bf237e9-d294-40dd-a407-e20b0c586940 69e64dec-26b7-4502-9b5b-314fe91748b8 d46a29ac-81d4-4da8-9250-7799cf5136ac e7db7170-9ba3-4263-8dce-43e8f238c8d5 6757337e-f34f-4be0-9ef7-3f4a0dafe32f e57e1506-e244-473c-b283-8f6542e2d0bc 9f24b124-9341-4593-98bc-1b8179cb23b9 b97abb97-08e4-4d03-ac37-cba2bf84ae59 57a6a622-fe30-431c-a72a-8c25665a6658 1c656ebd-b6e6-481e-93c4-33914476e578 c19a872c-940b-4353-a8f2-667770c4c8e5 e9e24e86-ef2c-48c2-ad32-1b46ad5d48c5 d54488a1-02d0-4394-bbff-e3e867d64937 47bb8b42-5e9a-4da3-bba9-f610a98e35d8 90702ad5-59b0-4658-aa31-a6a948aa7847 a6e2e260-9472-4315-b99c-53722a60448d 14f4a679-aad4-464c-a148-f4e36b1cca18 fe40ac68-6e4e-4db6-a10b-f332e048ce63 d41c1ba7-85ea-4db7-9dff-323d8331ee40 82d18a2c-7599-4c9c-9a27-4bc9ea2641b9 bffb4661-ba4e-49ee-ab02-a673a9e749e7 d781c376-b4a7-4bd6-8491-34262b06b0d0 4542e3c9-d558-4279-992d-ef76a848b0a1 9ede08ad-eed4-4823-9f8f-419a9ac232d8 150d4c30-972b-4552-9e93-4aeadfda11f8 30c6b65f-af81-474b-910b-d30c22e13f29 7ced4017-eeb0-48bb-8a51-380f7c713c9c de65c9e4-23ea-407b-acc2-09dd8c046e73 c23eacc8-c8f4-4bdf-96bf-eef1b8031209 bc326c30-bc20-45e0-beba-37280d284ff1 d592e6c1-8d0d-4ea1-a81d-8400dc375c29 082ae5fe-8d19-4810-9bf7-f190a184a755 9cc21621-98fd-4018-9ac3-f43bba957f65 96211cb3-7f9c-4dba-b031-1238021aaaa8 6f63d73c-3bcc-4440-bcf2-7e5b62c7843d d1d6fb82-44eb-490e-9c0b-3d2da2d6e247 1945e6f6-d48c-43ab-afde-f76fda918801 39d6bb18-806b-4b2b-b6c8-1b84a3313f9a e51a0562-4f8a-475a-b32b-9b74ee178503 6a00b473-9045-4fc8-99e8-df26a4702463 7c5b51f7-e831-486b-9f4d-14038ad3b836 f24366a8-33a4-443f-828c-a3868d155ec8 16a1a770-823a-4866-a7c6-47431c4ceb90 6e9cd9e6-6d9a-495e-b492-77a8253f8cc1 fb57670b-368a-4f4d-a9cb-7d66fbf6810e 5a4a06b8-9965-43a6-acfb-47c52706e3e2 4fde6966-d523-45dc-a1f4-116ab3ee88c2 a15aeff9-d748-42a9-886b-a7cd4750c626 d2382b0f-3338-46ef-b7cb-17d4360bea74 10770689-5660-4888-b090-4c7c7b48b69b ba29c06a-e23a-4483-b50f-c37531a681e2

## 3. Inputs and Contracts
Input: Profile metadata for Export-SearchEngines.
Output: Script execution status.

## 4. Execute
- Write Export-SearchEngines in export-chrome-profile.ps1.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "Export-SearchEngines"` or `bash -c "Export-SearchEngines"` depending on the environment. Expected output: success for SearchEnginesExport(PS1).

## 7. Done When
- [ ] Criterion 1: Export-SearchEngines is implemented.
- [ ] Criterion 2: Linter passes for file scripts/export-chrome-profile.ps1.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.

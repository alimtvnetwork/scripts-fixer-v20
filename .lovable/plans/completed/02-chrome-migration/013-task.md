---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/export-chrome-profile.ps1]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section13"
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
  tests: "unit test-13"
  ci_cd_guard: "linter-scripts/check-powershell.ps1"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 013 — Secrets Export Preflight (PS1)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for SecretsExportPreflight(PS1).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Check -IncludeSecrets. Read os_crypt.encrypted_key. Base64 decode. b15fd8b3-d295-4050-83a5-b394b1b0c8a7 215c8ce6-fbc8-4570-8482-14901e388c5e 2ab73190-8ec1-4fd5-8119-492a7c8b0a7b 83d5a6e2-731c-4916-94be-9c6c4e25dd25 c616ddc3-5f06-4776-8b99-c80c16c1c58e 96b41578-8533-4a8c-87d3-1c516ad6f93b 3a57cc10-bd9b-41db-9052-9cb99fba0af5 4074157f-ada9-4d37-9321-a3e38580c9ae 8573dc5a-b2aa-45bb-ad66-f16beba77e83 9a7a2ffd-b9ea-4b39-a23f-57cb73a99d88 f70ceb92-c0d0-4a5d-890d-07f8c629e461 ae0fa0bf-e048-46d2-a7c6-ffec249fedfe f5b651c4-b751-4cd4-b63b-246dd174bee0 6508d92a-e117-4556-82d9-6a9613252de8 4a8a7a5f-65f5-48ae-a6d2-e7ab5c9b059c fda5e5d9-ba1f-4c0e-9243-b1c85e685a6a 13d43e25-53f8-4e7a-a216-40a99911a61e 9d1731c7-8b85-4ec5-9d78-d483a5402448 9cd39b03-24c4-4e6c-acd7-8cf1c3ee5c84 be9e003b-e274-465e-95a6-770fcdd1c8cc a10d1c3d-d38c-4bd4-942a-39578d60c2cb 924163df-d3de-423d-8f07-02be3f6e2f26 030c1821-1d83-4a74-812b-935e4aafc652 3812b40c-23cb-4a55-a7d7-33150f25c435 53818606-ee1f-43cb-9fa7-75e6f8d0c4c1 fa81ba6f-d152-4493-b02f-ec2609fc88ec 14bf1397-b8a0-4ccb-8f8b-3c34c20bcb9e d267340b-b875-4b8c-8d23-3cff65e59d2c 2dfbbc61-7d0b-49ab-b626-3506403ffaeb d3a6fdb4-1769-4f0f-8eed-56f302d6b6ba a88eb71c-9af4-4a11-bf3d-0abf0d703503 f848cd29-4f4e-4534-8000-30b3eac08527 292e7bb1-973f-4317-89fe-b8fe63beab0f d702bbbf-db00-4a26-83e8-fb4d96064179 501b0239-00db-4485-bfa7-a6855ba74ad5 6ac11ff8-2053-422a-8c56-2d8bb4361e83 6002cc3e-d942-48eb-95c4-fcb742d6cf2d 6af73011-b37c-46c5-bad5-7e682ee35936 3033b6cf-e9d9-4e62-86ba-77f76293b79a 0b12f1f4-773c-4671-b044-1c46909a408d 4b91e7c6-124c-4546-9237-e11f1d8c78a4 b836c60a-398b-4edc-9e68-d9a201854857 005a27c5-8294-4f91-8f11-bb0a91d78df6 194d0345-ef79-4bf8-93a8-3cfe7c372d47 69cb200c-a9ee-4a60-8741-f07456b4636d d90e6b44-ad30-45bb-a7d0-7872b012a672 2a0900c3-23de-4297-a403-c107f4f18fa1 8e6b468f-d520-427b-9024-e5248df7f076 bf5cea80-785f-493f-9716-c437050f569b 58b55d28-b5c6-42bd-b8b5-3e8c64980f4e ee758719-461e-4845-958c-38cbf4fdfbab 9095d9d3-6b2b-4fec-b719-75d2cad30fc3 c579e313-4e07-40f9-8d4c-24423bc4fd30 352e1ac9-afb3-4036-944d-e37fb8ffe41e dd7db18c-d7bf-462d-a475-d2e7725dcdea 4f3047da-8ecb-47d4-b885-7f12426c66ec c1f02052-2376-4133-96d7-98e415c69ae3 dcc88a5e-9ba5-4ed0-a815-d008b36fd326 8dcf946a-0f85-4430-b282-55f5f1d749a8 d19a631f-43c1-448b-84a2-1ff4e424d883 d04ecbd4-90cf-4da8-9345-30825ed525c5 12c85aa2-96f5-4ec0-97bc-dcb5cd4ad48c a6d5aef5-32e7-404c-921a-541ebf58c504 c73c71c1-b470-44a8-87dc-04bd671e2987 20d5aab5-d105-433a-b163-1cebfa360884 b1dff541-affe-48cd-814e-4fe03dae5c02 eeb08ce4-8360-419a-bec7-91d4311f3aea 9d2ae283-9494-4472-a3ae-be8484eee1d5 8891c0c8-0fb7-4761-a54e-eb7ca9f06292 495c6c52-396f-44b3-aca9-c6bd7d4a18a5 08778c16-4c6e-4c81-8efa-0c5cc30253ef a7b50b5f-b014-4bde-9449-45d82068594b 0ee0e46e-986e-4df0-9d6d-719ca95b58c8 2a688452-ad4d-4a5e-a076-2698d2182443 76013fbd-bd26-474c-a971-116ed37b7b08 cdcdfa4a-1abf-40c3-8f9f-7432934ff7c1 7b021f40-07e7-4346-8619-ca503c08478d 031e4e5c-81dc-4335-8cc2-8fae395e7094 4b3261bc-a793-4ef2-856a-6729cb8319d1 eee41c3f-e718-481d-98d1-89094a58c565 40d44756-ef5c-486a-b444-f24e7b3cafe8 c659e982-4f37-4327-bbe5-188acaec5435 7b95a8e8-e735-487e-ad29-727cc8a939bb 308acb0f-a10a-465f-ae3d-0a2dd1e1b448 6998120c-a345-4bab-8bc5-eddf738a2835 8185e45d-50af-49ee-9a10-343d86d9d18c ac545acc-e243-4c09-914b-e3a67768e1b7 63b863ea-57ae-46f9-a23a-ca6ce1269f4b 2e8595dc-4228-4be4-ab8b-b003f3c01ea0 04ff7ff1-f9f9-41d9-b807-238c2891141f 7abd9e4f-f784-4433-bfd8-a5fa52fb6edb 5ba82148-16ed-4c67-b5d5-e45d00398927 46d4dc4a-bbb0-449c-8305-ab5ec9a9e90b 56573ea1-0cc9-4964-833e-2b504dbf75f0 ac62ab30-6107-47cd-8286-c28ae038e8a7 22f59876-34e6-4e50-889a-879ac3f6c733 9852e32c-c556-49fd-a622-b986aa308174 f219cf05-a17e-42a9-8ef0-4e98960fa8bc ed098392-fec3-443f-881a-a690b54f7ae3 10994b61-752d-405c-a4d3-5d1b0aae35f0 5bdc3d10-d37c-426c-a400-c2b91d03638d 9bc838f4-dc74-47c4-b87a-ae7fe95fb241 35bc241f-e1f0-45c5-ae59-da318c12a6e2 063afd66-9066-4384-80f9-dd44151e12f7 83b3a1ab-eeb0-4d39-9d0b-08e3ef5ea303 dfe01258-e4ba-4922-968d-3b6b37896451 b59f128c-f805-497c-b034-1e03356adfc1 cfb0b9b3-c231-4eb3-b744-fd2b6da6b1f9 5346fb48-9e24-48f3-9a83-9b9d16fd6ac9 d57ef771-ead8-4a71-9a44-9c7f0586b49b 6575c15b-8696-4ed8-b1db-be7fa0227ef5 34bfd0e6-89d4-4141-9444-18b0867f29d2 17f82209-6616-4c11-9684-38251a910d07 74129a5d-a9dd-4d80-b205-702719f608eb d55a4260-259f-4a01-8b09-5832d41a1263 a785f098-310f-476a-a18c-2d02b961db58 1800ff2a-907f-4839-a6d3-765c431aa516 f43f9319-5b0d-40c0-86d5-6fb87736b381 c4c0835c-4a46-45a5-9e67-812d51a39f08 214651c8-ed91-4a22-88b3-ad4bcfe14d5b a0f954b7-b099-4a68-aa6d-07c6d8368b39 873200b9-9c2b-4f59-a142-2ce3ed12f02b ca8ce5c4-10a8-4866-bfed-1a9c92e4aab8 22a5a075-612b-4f25-b68b-85b19b5bf9c7 99b82311-bd8b-4a13-a3e6-aa62c1285a88 a2837132-d1e8-4cb6-bfa3-0d14314c4661 2f65d925-d0b3-44e4-82ec-3e45d59e7dd0 6b3a0465-42d8-4207-abae-cf514342d1dc 8da912cd-e6a2-4015-a81f-de629c7eb9d6 61bd7f87-994e-4951-a5d4-7d7adfbd0a21 1486cf29-e2c7-4472-a869-0170f9487bc5 e421bd8b-4153-4c43-aa36-b32725a23ae4 d5847633-bdf7-4a7e-a168-1c514ae4c6c2 a6df9480-22f9-4374-93f0-fdbb1e551bab f1c0c502-aa0b-4928-bb83-ca30cfefcee0 0c5bb581-aabd-4928-903f-7f94002876e6 5959c835-7444-4088-a8e8-c5520f1c5848 d389208f-89e3-4214-8eac-7a5c15b6376d 1027174f-360e-4401-ade6-f0e8bfc1bae2 60eebbfb-3f15-4f93-9829-19fd2f72cb31 76b86d1d-513c-4742-a216-f329067402e2 88c0be6f-616b-4ce8-8007-937980531bf6 a1a9b403-3855-4786-b1d2-6b16ae830eca 1cfe6b68-e9ed-495f-b0bc-235dc4c8120f a54dfd96-b3eb-4e8b-a8fb-e28466ad7e99 17950072-9c84-45a7-b57f-c1c566e6118f b503ad79-f5fe-4815-876c-5fc8c75cbd18 3375bdee-a0b7-49ce-a485-e480ce5b7ce4 0d3ebb3b-0431-419a-a85f-3c7c731e6267 3f5a1166-d91e-41e4-a35d-a232f29ab6d4 69205973-b6b6-42a4-a50a-11bed9349cc8 a0c68381-c138-4f60-8ae0-248ed02f7d88 3c439d3c-97f4-4723-8584-7cbdf619d1e9 ece074ea-98cb-425f-9202-2f6e4ed0f933 dea7b348-98f7-4253-bde4-1e6df898a91e 9180ea7a-ed53-4948-8be8-cea7fcf1a51e da90897b-b8da-4e37-b085-ea60e0553f1f 26b40111-2b10-4a46-ae27-50ad211bf9a3 737028c1-13d2-4fea-aa53-36493d9ca76a bcdd82c2-b1ea-426e-be50-e99a4b7bcdf4 afec9af7-dc84-4607-9d4c-ecf936d339e8 907dc30b-b7fb-4cad-8180-f1bdf1bfe4d4 1f824623-e9f5-4727-bb6f-f42ee2f1f86c e928c2d1-fd25-424b-8cb2-8345943ca172 9a986aa2-f91b-4e1d-93d3-8883bc441f3b 3640c974-571e-4643-a436-994dcddce7d7 5631459b-15c8-4887-9f75-e33b0b4d77f7 e97508e7-873b-4082-8238-705baf8586fb 9b583124-5b06-43d1-92d6-d37047b3e424 f5cfe02a-1976-4b8a-b54e-b244a95185b2 8ed2bd95-1070-45b7-b9b6-13b812441549 95cfc4f7-7a00-416c-aacb-9d37e2a5be94 2e16e206-206e-491f-adf6-a7bf4cb70e47 b15b445f-82ee-4413-9433-48204b65ce4d 258df1ec-8695-41cb-86b5-96e7d70978f6 38f1618e-3967-4f80-b31e-a906af6cfb49 6978f3dd-efb4-4f60-a95e-c83b8708c4e2 1fbbceaa-c627-4553-9085-457fea4a95e4 1aabf3db-53f6-404b-9acf-42ea9ebfefbc 301fe65f-5c27-4cc3-9872-85d0a28da7cf a5224051-d0fa-4c59-bbba-2017b28e1cc7 3c51deae-66b9-459c-b5c0-b3f01364aa82 181717cd-b489-48be-8369-3807e3e9ce1b 5a489106-9bbc-4003-ac2f-f44c64b06692 85595c3c-d930-4805-85df-5742fb68dfdc 45636d58-bba3-4ef8-acc7-c5435fac5f8d 74891758-8d9c-4a71-b4ed-a3cbc8465788 b1e9b76d-a90f-4388-822a-af3716e69682 165b1d23-0cfe-4c8a-9f98-1e45a45972e2 12c72128-2652-474d-8d25-f2bc33b68dad 28aecee6-0a93-4008-a50a-00bcec0c0a82 5027af59-775b-4801-8469-a13518b3dc39 ef7667b1-ed5f-4038-bf40-54f1667209c6 24999d91-1171-4e2b-a6c7-f18a23932057 57fd60ad-afed-4a5c-8d4d-fadd8a04906f 6c6b8d9f-7bec-41d3-85c1-bdc52232a9b1 0a0b4c24-b60d-4a5d-9148-2fd1c6f52af9 ef75722f-aec9-4460-a3b2-8b39648875a4 56af8acc-861b-41b8-ac5d-106f294c6279 9073d498-fcf8-4aaa-adbe-308e600a7bb0 b9713192-c0f9-4a7a-8a73-5ecc33fdf8ac cefc5d7b-91d6-4df4-b5ec-6105f8b6b100 095eae76-e0ca-41ca-999b-5be1329f46e6 88ed2841-1ca7-4daf-94ed-157757737114 aa475471-b182-48e9-84aa-3d3f3c6f80ca 13a263f2-741f-45b1-b6f2-08d66a0b8ac6 98bd5f85-01a9-4f2a-ba8c-5545d382ca62 32a946c9-a449-4033-9a12-5c06de891908 89249055-4ff9-4771-8029-154b999057ec 69aca884-1be8-4114-997f-4052e21a3a2d 6edac793-2b34-4156-a3ad-cb70ecc1030f c43e9644-e9cb-48ee-9f3f-581c4102466c 7a6c9391-e217-4a4a-81ce-f3167265b974 a746b22d-7b64-4744-9866-ca99bd007cbe 4d336d87-b867-4a69-b2b2-f43a91c246f7 fc6a78ba-cd31-4b85-928c-d46bffcd79a7 2484d968-0680-4562-a795-007274a6c589 a77dc8f8-cc84-496a-8f7f-028b3bd5e686 ecf8732d-3e04-4987-a838-e23fde9af2c0 295d5101-41fb-4569-9ee4-b6c00a3223f4 c597538a-25ec-44eb-98a9-3051bddf732a c780e2d2-c373-415a-888a-7bd14f4e9c7a 6365aade-773a-4506-b3a0-431f164528bc b3443372-3e4f-49b0-b3d2-1a0ae868f830 d9bb52d9-1ff9-460e-a69c-b905a39dde05 7eee1ff7-367a-4924-a041-2b8e0c83b4b4 e9ddee60-8956-4125-b813-b0bf1ab5cf8b e9944581-33ba-4094-8af7-6d83796f0da2 189a71fb-eb6d-4779-ae9b-45990670525e 95a18672-eec9-4018-85f3-02d2abd9b6c1 7fbbd6ee-2be6-4bbf-8265-2523dee38d0c 9d61b6f6-24c6-48d1-afeb-46b14b8c1ff3 a1c58414-845c-48d1-a812-2dac62efa301 821c1102-e784-4aa7-9b56-3311f3485793 b1bcd164-12b5-44b3-87f0-2e1f3a9cfac1 04a61e97-b04a-4068-a930-b83bf08061f7 a8161fa1-d456-449c-a194-11fc757c6ec0 7516cdfe-f07f-4104-94f5-0cab8b46de6e 74c76b81-e0d7-4f99-a0ea-1d5f355b0185 a9fb3ef7-e57a-4ab5-b255-e6d970379acf 62769e58-0d3a-46e4-8a65-ab1b771ea850 380e4e95-e550-44fc-b596-d990fa1b1e4d 90ab1098-9b55-4faa-b41f-84b96921db1f 62181189-cd70-4e2b-9f57-f7a5599704b4 bf999541-a39f-4b22-bcf7-44c8dc8b73ec 2d8554f9-75fd-4193-b753-69627ba50d22 ba324e4a-cdca-47b8-830e-12c81bf41c51 a481f983-9532-44d0-a0b5-7d30be5e6c64 f661d0e2-1116-4ee3-926b-49373c33a6ab b46e981a-cea1-4a13-8978-c9d062de7529

## 3. Inputs and Contracts
Input: Profile metadata for Get-OsCryptKey.
Output: Script execution status.

## 4. Execute
- Write Get-OsCryptKey in export-chrome-profile.ps1.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "Get-OsCryptKey"` or `bash -c "Get-OsCryptKey"` depending on the environment. Expected output: success for SecretsExportPreflight(PS1).

## 7. Done When
- [ ] Criterion 1: Get-OsCryptKey is implemented.
- [ ] Criterion 2: Linter passes for file scripts/export-chrome-profile.ps1.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.

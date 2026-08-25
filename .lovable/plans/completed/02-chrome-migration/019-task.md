---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/import-chrome-profile.sh]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section19"
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
  tests: "unit test-19"
  ci_cd_guard: "linter-scripts/check-bash.sh"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 019 — Importer Backup (SH)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for ImporterBackup(SH).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Copy profile dir to .bak-timestamp. Setup trap for error rollback. 807e860f-9f38-4914-a144-f3197b76c504 34e15cd7-5eee-4b11-ae58-63caf8634ad1 c69d4348-9e14-44cf-b469-d925365fec48 6af66d02-34a1-4b5c-b8f5-d84e323e7a5b a74aa51f-2186-49ab-8942-609897716b87 51488db0-b35c-482a-b091-f2dcc243ea92 8e6d7f96-c1ec-4e52-aa2e-3ad9526fd346 a92c1907-6a3e-4fc3-8fd0-2d2e26845ba0 92f5fc1f-cf1b-4eb8-9742-0ee0e02f6341 5a1208fd-41d3-4762-aff1-6d2fb9295588 0793d4f4-4c79-4a05-8058-c681f317cf39 52e61e3e-9cbc-4b65-ac1f-e1a1d9f90607 b0f03a21-9b36-46cf-980e-946ad6649d2e cf44b304-4481-4c14-a4e5-aa33d5218391 938f24c5-3386-4271-8921-767d9dee68b2 4a106679-3167-4645-8949-47f3726a6535 015b7fab-f3f1-4641-8407-23dfcd07b704 4dcce8a9-ca90-41c6-a7f8-8cdf205dc439 42fa4419-0bfc-42e9-861b-af4fd6c02b63 8ae855ac-d8d4-4b8f-874a-4bc606d3e1e0 d831bdc4-c646-49e1-a553-b5ef3997d015 994cca2e-7711-4027-a8a0-10bba5ee4ed4 0b72d079-0802-4ed3-83f6-9e545290ae01 1606d8cb-cb72-4a66-9e48-efde6f118b00 e6bbee48-975d-435d-b396-6bce29e9daf9 f6e3d456-457d-4b5b-b836-e36b6cf12ac3 8f3b7b1f-17d5-4365-b934-4b261c1e03cf 713136db-3c52-4dbc-996c-ade61029cc28 9d583d05-98aa-4348-bbdc-f90ee78f16fd 1ae18749-73b0-4a22-a39d-058a14a4fc84 4125ddc2-8fc3-4d8b-8f84-159b6f04effa fbf7e48a-5229-44ed-a2e9-81de252aa688 8b701e1d-f4eb-4cd3-92d0-48bc7e1877f2 8a9e4128-e609-45e7-9040-e1176d308e17 179e3a8b-e689-45ed-aa33-8a7335e09810 cab2ad5d-acb9-4d94-a22b-edfa989a2879 16ae8c07-aae0-491c-af05-ec6bd9eab8d6 b08ca775-1812-4ffc-8341-6566f2a9d19b 1b25ee93-b18c-49a7-b30c-171c304803eb f904126b-12ec-4a29-970b-f21e11644f17 693c6377-be44-402e-be68-231ecf5355e3 8563b09c-6f54-431b-b792-cb66797064a8 9339a782-2ae5-4b08-aff6-80beed787877 e5a52b71-7708-4310-8b59-2e993d048285 a81d749d-3406-48ba-b1e9-496eb60b5832 da523e51-4db4-48f1-92b8-263b2d0014e4 79440d26-aa2d-4e34-bc4e-a2f21a95f288 994cd65d-d223-414c-84c7-ac55c298a042 68c1ace4-1135-4d4d-8c53-8c580ca84cf3 b3a5a1fe-f8be-4dbd-a900-4775112b5732 0148f3cc-f189-4930-8d5b-26623517b763 892f7b99-bbdf-40f5-9d48-2523dd2abae5 8702bb34-7587-4592-86df-9442c3d4ecd1 add647b0-0206-4904-8ca4-2c2ed96d2ee4 07857ab8-1a04-4eb6-b732-f4261affe19d 9740aa48-da66-4f27-8d7f-8333f8780abb 6636fba7-1290-48da-9101-bbc67362368a 2136b7ab-8cf2-41cd-b4d7-a4eaa5d4f7c7 a27f198e-d928-4d0f-8606-0d4be6011013 fed3b9c3-eda0-4f17-9de7-28792dd548ee 5d6edc1f-8324-4d4a-8fb7-b1e4bfe50827 722cc4e0-c95d-450e-b1b5-b1ebdde6ba5c 7e30848e-bb63-4e59-a50c-c6e23cf78b95 d6b77e5c-7415-4cec-9b4c-2547251d5723 c447aa95-133e-4cca-b941-a4de4b00872a 3e9ac673-e783-499a-a075-ace16bb19791 de89b900-eaa2-4935-a643-0b81712d0b55 38424980-07b6-4151-912d-e9fe875c7b4b 7c500859-9746-4163-9f37-2579cc4d65ed 467cdc3e-5a86-4b9f-877d-d43150db8d11 f9bef0f2-c32f-4fa5-a786-ed2940aaaae1 a7013b10-15c8-497f-bcd9-fe5e13e0b291 bbdbf31d-d0c5-4ca1-b8f3-7b4aa7e6ff3b c598521e-4974-4818-9d62-d18d1926277e 3cbdce08-a638-4ef2-86f7-542646dfccca bf5b1d93-68fe-49e1-be0b-50d0a0ae956b 55495e23-7aa6-4205-99d2-41a64df65b15 29e649aa-e218-4fdd-8f0b-a57ead9d888e 7ef6a958-7f56-40f7-8f52-15e536159f4d 5730da58-f9d0-44c6-a2f5-87b36216e0ee 5891f00b-24cb-4c41-9c4f-baef90b88bec b78aae5b-f979-468d-8270-efc4e7739165 98b134d9-f577-44b2-b9cf-89c0687c41d7 74988e3c-4d26-46c7-acae-a8327eae97f2 6428f507-7416-4543-bb74-50a49a6c94f0 69ae1af2-1910-4953-8901-8cfe36881f25 dfa094dc-633c-419c-b3c4-d313e5533335 bbedb7d9-a7bd-42aa-935e-ab1cc359f53e f18255b7-25d4-492f-b472-dfdd9cf43a1f eb33e7db-dea6-478b-9bcd-4ccfac2f206c be6ffe2f-82b6-41ec-874a-0bd5cf935518 91fca88f-f5c5-44ca-909d-639294c46d74 6b78cc88-99c0-45e5-9f31-a5a926cee982 49ab58ee-e15f-4b97-a311-bd07cceaa3e0 16b897f4-26d1-4ae7-8bc0-9148a71ae2a5 46a5b692-1624-4af8-80a3-cc9fcd9a1e3c 7d186ca6-b74e-441e-93d3-0e73c1e8aa2b ae2743e8-20f3-4d65-9f4b-4614c4e677e5 bca2317b-20ef-4889-bef1-0efdc5e882fe 8708727c-fc14-490e-a59e-e9b1913dc72b 76a04840-b4d5-41ae-940d-257773d011d2 7b63a061-a8e2-45dd-a514-34726228f014 3b04ab4c-1154-4cb1-ac9e-f193239c2702 2a4e8e47-300a-4923-9bb0-9ffb607ac821 8dc053f7-a1a2-4012-8578-f3b64055c2b3 3854cc54-8745-4a67-a297-a7ffbb9580f0 7b78089a-ab9f-4501-96ad-be140d4afdfd 56de110f-0d5e-4f5b-ab24-32baafcba16f 362bfe67-9520-40a8-9b33-9fd14da8e252 d1d60a10-332b-4c8c-9dc0-3ffd46b237d2 f556dba1-7560-4783-9816-a6b5bf6851e5 2416a1cb-32e6-4ffe-9ed6-cd841fb3d9bf 57057917-6b7a-4cc3-a40d-bb71c3314711 1ab84538-d1ad-42cb-942a-5df51e952bde 63e54426-4c2e-40f1-a9f0-68468ec89891 e2465201-de7c-4bec-9dab-a49daf67ea05 d947a099-c7ab-423c-9c41-1c61e13aa51d 534a21b2-16d7-4538-b7ff-583e0ecc1d15 15e42701-8fb7-4b32-8508-0f09cdea409d bb9910da-7dd9-4a3d-84bb-3286388790b8 bb705d6b-c430-4552-85a6-859ba420d6a2 75b84566-4793-4e38-be7b-b548370a4a20 0c8d7d97-e295-4a9f-abee-3c63a9f79cf6 6763ea74-acc0-4892-9677-a1b5dda34cb8 1d1ee716-59a6-4ad0-a15e-3639174bd052 82947dde-3f05-467b-8839-b6e095280c75 89d8fdcf-9567-435a-b248-c0cd4923a7d3 65687a06-bce6-4dea-bf7e-72bbf6496246 d853e989-551f-4c4c-b6f9-1ff77d7ba63f ec09fa9a-c366-4bcf-9671-c22a27164c67 f8ea1f4b-d649-4510-b0cf-bf19a4ef4c2a eaed8ad5-7ff9-4886-9dff-cb4fa550bfda 28d500da-94c8-4557-9a1b-360c30237497 9c394322-328f-4ca9-a4c3-8cf6cc340939 5da98da1-db87-4940-8fc8-baf2b5fc58af cd0acc51-e08a-491d-896f-e846eaf8181a 89784a83-6c80-4254-bb35-fb0f348a3d71 29cbe4b7-1164-42c7-a2eb-ed1613fd0215 18f3da5e-4af0-41fb-9ee7-059d51cca9d0 febde428-0d8d-42e6-8b79-c437b10385de d6e303b3-7125-4aba-9d02-eaec7a2f68dc 47dbb6c3-9fd0-45c6-a2d7-b693eb4ec5b2 f0227494-3171-4858-96ed-20197fd7831a 3d1e79a7-720d-44fd-9042-e536705187fb 8ecc12bf-2f41-46c3-9122-dc98e34970e9 7f7d57a3-6288-44a0-a230-a42fa7d63406 e0e63517-aed3-4eaa-9013-1a992be44d66 128c741b-82c8-4200-a212-df27d5c17351 4fc980cd-f591-4219-8945-f0b223cad6a2 c23a1152-dab6-4bda-be69-6280ccdc4e60 79306fba-2e79-4892-8ec1-51766fec9ab2 4e6658e0-5d9c-4a5e-aa9a-73828a14b8e1 72fdd4b1-250c-4eee-ab10-377d2cca5387 0b6c7650-a186-40fc-bdf1-08e5c8bd7e74 8e853858-ca2a-4992-bfec-e7cb73540ad4 80fd73b9-408e-45ec-beee-52d12ca43c9e 9f4acd68-b083-421e-a228-33db1baf9838 44b02f77-b9b1-4fb8-a6ee-db92558c230b 150caf85-8f63-4499-b951-f42a4839e26c 151dfce4-6d8c-43ed-8a88-e225fdd87bdd b9620974-9bc0-4a69-96a1-c78d465e80b8 b4ae0e8f-f125-44d9-b0e6-be4daab3f358 d82e1418-d8ee-4edb-8b8c-c2e12b03716d fb9020c1-3ab8-4c4c-881a-f807844d4175 45252960-a0b1-4dcd-8420-87a71db0411a d3d5a270-d72d-452b-a387-ba7b59844a4c 3dbb68bd-9415-4aee-b820-4f4d7ccf62d6 292925e9-1ebf-4365-8d1c-5bff9dd2ae07 816be326-43fb-4cdd-bcc4-c99727f4baeb 62ee60e3-0f25-4746-bd19-6a569e9f71de 447f8e23-f211-4115-9664-696b5968db00 0da13832-ad0b-4c58-9fb7-91a64a81e07c 99a8730b-eefe-42be-b44a-c7fafa162b75 4829d221-331a-45a4-9166-c6798a051c42 42964624-b2f9-4ba6-8936-b113d333143e ae3ff7a6-8fd7-4df5-af9b-5af6a63f6732 2888df6a-91cd-4b15-9ef0-261cd8fa0d37 47d85f13-0ede-49bc-bedc-d2dcfd814a20 6ebeea08-0091-49e9-8bdb-a9c9f77c805b 628437be-8b52-4559-be56-12f886c4b434 99607f7d-b45f-4488-8bd9-0eb66f3ee90f c81c7390-ddb6-4328-8591-c0f5c171258b d1979c4d-f2e3-4626-803c-2a10b83ce9d4 0388b4da-1aac-4616-b7d0-e31720da440d 48f22791-8769-4850-91e9-7bb43a650f0e 29bb4023-19df-48ca-9764-deafdd99dd7f 0b899392-33fa-4f60-b12c-5249a303c014 8fb3ef4e-4e92-496f-a1ff-72c743406db5 4ec21d3f-c52f-4d9b-9d78-b4d552aa1b74 a67b951b-d1f1-4d5c-866a-014cf6702761 8c497e22-dc1e-48ee-9d16-b9ebe6540bfe b5c72130-4d95-45e7-8f0b-eef0c97ed757 9a3e082a-8ff3-4db2-aa5e-1d2b0405317c e14cb14b-cbc4-492c-a442-34ac1188b40a 943f28ed-cc94-4aad-921d-cf83623e31ae 1a611a13-73e8-42b2-96a3-4a78286447a1 d892e77e-5170-4312-ac72-017e08a23c88 0e14dacd-de3c-442f-ac0a-a1d7e947254d 7b06b7d6-d80a-4a63-809d-b60a81d71c6f c85640af-6487-4234-97a6-3bab51d44d64 809645aa-bb64-48e2-a3e3-fe2ea45b94f1 489a5663-67c1-43d9-a182-4e7543146af6 a9e76bb1-bb67-4240-8199-18a0ca8fe9fd 498f98f1-a080-44ec-b005-857139483698 ed76a70d-37f0-413f-b566-3bfee2446ce5 f6fc4259-7782-48b6-8edb-c57a91f959c7 f448b388-193a-4823-a2f7-c8f06ae76d40 8dacfff1-71a9-48c7-beb6-daee03b03a64 e99e7506-9996-4731-ba54-79f7a2029068 5ab86d9c-146d-4dc8-830d-8235fadc1c6c 17256ffa-d8d4-4fd6-b430-1ced570dab40 90847a82-542b-405b-abd1-4aa837dcb7fe afbd050c-569a-42d1-982f-9cda0ec3276e ff08e496-3368-49a4-b1d5-8417252c73d3 d498e6d3-76d1-40f2-bc78-d673844c6617 4ee4b9e7-cb3f-43d1-b35d-bb30432bde0c 76ed8963-5b4c-4e1c-8a62-20e34c8bd9fc a8f1be39-f4a7-4d34-afc2-752d5a8f65a6 eaa64bda-32e0-4b8d-91a5-fc9a6b3070e5 b12a67e7-8e0d-4084-8016-c12d6fab98d0 205b2b6e-0017-42f1-8c61-36889f3ee232 abf222eb-359a-4b85-9b2f-1ac136bb3719 15da1ef7-97bb-4f56-aecd-a482517f44df 8f338e5d-fd55-4555-a0c0-1ce570b2182b 3d80214d-7963-4b78-84b6-063f9bf1b18d 5fcabf43-dba3-4921-9a29-2ebd6e9051c1 8bf877bf-6809-4519-8ea7-c922f7ec89b6 f01eb920-c17e-40d2-9130-4e4309c37859 79cfad3a-38e4-46f0-b29f-0be7cc1ece16 6ec56af0-f57f-4696-b234-5fd7a044e94f 4ba73f60-4f57-446f-9c0d-83daf44a420c 3cd18690-0a89-4f96-98b1-b44f996f86cc 635aa034-2c91-401e-96e9-9e11c8fc7045 960d37e6-e7b2-4367-a198-2439888a9683 f2d24fc2-561b-4e67-b60a-8264c285f7ff 4de38fd5-887f-422f-99d6-7355fdcb13b1 431666d8-f3d5-4e0a-9c98-77e47b77cc63 def53821-5cfa-464d-bf5e-403e90dd191c ccdc969c-a1cd-436d-b33b-e6649bb1247d b6d30bd9-62ad-436f-b7f9-3663d337363b 2fe8255e-8b34-4f8d-8382-33bdd087b40c 27efdac2-759b-422b-888a-feadc320ce4b 72f4de1f-60de-4076-96d6-36e5643562d8 7944ea7a-9b31-4ed6-a360-15f113074d75 c44b2594-e242-4a17-ae1b-98b4a0e38d89 cae3a318-225a-4c01-b9ea-0b804686d515 820c470a-021e-48d5-8efa-4ca390b7fde0 dad9b707-ffb7-4683-9b13-b31819e962af 04120b9a-a115-4295-87bc-3646125c2312 3711153f-3afd-4449-8029-1a679e1f2038

## 3. Inputs and Contracts
Input: Profile metadata for create_backup().
Output: Script execution status.

## 4. Execute
- Write create_backup() in import-chrome-profile.sh.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "create_backup()"` or `bash -c "create_backup()"` depending on the environment. Expected output: success for ImporterBackup(SH).

## 7. Done When
- [ ] Criterion 1: create_backup() is implemented.
- [ ] Criterion 2: Linter passes for file scripts/import-chrome-profile.sh.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.

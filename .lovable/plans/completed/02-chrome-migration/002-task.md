---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/export-chrome-profile.ps1]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section2"
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
  tests: "unit test-2"
  ci_cd_guard: "linter-scripts/check-powershell.ps1"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 002 — Chrome Process Check (PS1)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for ChromeProcessCheck(PS1).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Detect running Chrome. Fail with exit code 2 unless -Force. ae3b6541-65dd-46f8-aa4c-b2c51d039b59 e9d2ec13-cdb0-46cc-b2b0-f32337969477 8af9be24-4001-43b8-8c4e-a9533d2c3766 eb174f2e-fe1f-4c6f-ab84-903706511a51 4a635226-6232-4320-ab9a-b361f8da6505 8f0ec728-f143-4bc1-98b9-e903931d9e73 66129299-47d0-4f9e-8d69-34fb3d782aa9 f77b37b4-f11d-4da5-95f7-d13471de95ed d6fc7c8b-2d7e-4624-b949-628d14cbcf1f da7b130c-689c-40b7-816d-3dff70730c85 f74a5dc3-b33f-480f-8e7e-af696b4fb39c f1010a86-dd85-4a1a-ae68-cf687e267e0e 525c25f3-cf9a-4750-b9e5-1a08308829d3 6350af25-7a58-4f19-903e-357bc869ce7a 5b1d82d7-9fb6-4319-b9fb-6304fe4bbb7e 9dcf50c7-7f32-43ac-a05a-4b40ba28c8d0 4514c1b9-9823-4e89-a0e4-379b64f5bdaa 2bff2506-0a53-4ffd-8617-2c87eca1e73d 5d88e854-3a8f-42ae-b9b0-621d1f841295 2714e78c-6294-4845-8992-de33e330224e 6ce50e23-546a-4480-94ca-5b7617a529a6 bbcdc992-06e3-4787-98dd-ea7a5fa55c5b 84aa13da-1e3c-475c-bdce-96aa91790476 bf27f031-c82f-44a3-a021-a1b08f39f4fa 5048d5d2-4e81-4fec-aaaa-10acd21f7ff0 22f66ffc-8676-44bf-8e47-e46906179f13 3303312d-a736-4bca-9691-71b994721f22 d9dc9075-555b-462a-83d0-8ad712c1f387 5242f386-49d7-45bd-8790-634e4f8a61cf cb38a444-4e33-41e4-ba9c-40effd10ca4d 6fb0d656-11a8-4f04-ade7-b1698bbee3fa 04f2d19b-5e04-4f0e-9e2e-ad520cb2414b 9f403dab-f097-48f6-8038-0fa0488e1e8d 54293cc4-c18c-4615-9100-a9c6b3617f50 6086514f-de23-4e99-8ae0-3a8c24ae45c1 c4b2d969-445e-42d1-87b7-6fb86ad27a26 84f50683-545d-4d7a-855c-5ef6b10551f9 100cb72d-557e-4254-a4aa-5b8aee335937 ca96a772-acdf-46fa-9411-c79c646d968f 1ad2236b-68f7-4855-98cc-8dcff9716bb4 6f35f60b-362a-4077-b28b-8a28fc31aba4 71a050e9-5dbf-4744-8780-fa12212139fe 4789521a-e900-4e83-8a10-2d8b292fa0f6 fa0512a9-df43-4da3-a4f2-dc2d463a4c1c 9418dafe-921f-4d94-ade9-727b833aa935 789f37b0-c90b-4802-ae03-4002aa107fb5 2b22e4fd-e5ab-4fcd-9395-02633dab13e0 f905b69c-83a0-427d-b023-f7a0a71e1065 36aff277-7eec-4922-a20a-320567088fe9 758da389-ca1d-489a-866a-992f005d7e62 571a872f-daef-4cc4-8156-90c46b989720 01c81a18-aea8-4d68-a06b-e7b64b749cd8 a57d95bd-98fa-482e-b74e-8c6e48f9ad96 dcf514b2-e63b-4c53-8eda-e6deadbbfcda 5bf6352b-35cd-4eaa-b0d8-61f7df5e2c73 b500ebc3-7a26-4f4a-9e35-14ad7567d3cd 1ba2a946-0af6-41f1-ba97-11e348594b06 ee66ff05-e4b5-4543-8a77-1a1635f5af36 e7d2230c-a4b8-4b0f-b522-bb62b0f2da47 c8a9efe6-d1f7-49ac-8e34-4fcc2ab70b8b e1d9dabc-5cd8-4265-9c4f-e54750b0ab76 26cf00a0-eb88-4e2e-b183-30c0b58d1388 97114980-054e-48ee-8453-f40d4b06bf16 bd92b20c-bd23-4083-bdf3-893aecf86e6f bf34f8d9-892d-40fc-833a-630cb275e2a4 4a8d2ef5-cbdc-4baa-b1bb-964972ae8368 182475ce-7bb5-475a-a121-fbd24cfb988e c0e14eb7-6424-4f07-9101-6fbb9f4a94bd 6e8d31e7-f07b-43eb-bd86-9e6104e39cac d3a9b148-1472-4a6e-8267-2cb6cc948fb4 5802ef52-d054-4070-909a-fcc41e4e42dc 2b5e9d9a-dd63-4d32-aadc-0e5ff777bdfa cf6422c2-3354-47b4-a2d7-e6d08ac84443 faf4ea62-efd1-4c05-93b8-eb6eaa04a60c 2c7a7487-2baa-47fa-ba3f-f5fb94758cbb be6f88e3-f822-451e-a8c0-130224afae83 f1128310-2129-43d9-89fe-37ad37d56d38 1b487ad7-6340-4b73-b59f-b1cd18305ac4 a6f06a9c-724d-4fe7-ac79-67da1a67bc2c 436ccc4d-504b-4723-b8a5-7a80a7a126e9 b5021d07-4f26-40fb-9844-d3d613380d8c 3ee91199-f39d-4ea7-8480-9716ed14cc79 53bae64c-495b-46e9-a43b-fb6644f577ce 6b0146b8-ddeb-4881-ac88-4683832a07e0 a4f25b70-e032-48b5-8c42-3d1c322b5d7a a7af2307-0bac-424c-8322-3f064aad7600 bfee7c71-74d5-445e-ae66-9cac5382a7d9 0e102537-6976-4c71-9c8a-871fb272f696 8e44f3f4-e9e9-4863-bb64-922b2c3de2a0 199324aa-1313-42b4-a81e-7dd63a1a59de 4296faff-61b7-4a38-b028-fea0e7dab697 7b9d2318-d7d7-4f6c-8388-649dc7b5ae19 c054b3c9-7b4c-4356-ae44-b25a67413dd5 4c46f4f3-5b85-4b12-b5f7-8f91f0e82578 79aa7b77-81ae-4ff7-8c32-890a1ea2f2c1 55fde472-6c9b-41be-ba26-7f5e3cf28c0e 114b892a-6ee5-4ed1-b72b-a168486e1e26 047851c7-84b4-477f-a673-37ebb3e376f7 fa81a606-1677-4441-842f-aaf55b2e1c03 4b7249ad-3965-441c-9a30-bec292276fd1 7ac9639f-df06-4573-a4ca-e64905d93e73 c9e6ecfd-94f0-459e-a268-ea6a010445dd ddaa4f45-2c11-4892-ae1e-2671d3e273ad 80ea0225-8b9c-4eb7-9826-48c58f5938bf 19aad789-6eb1-4a54-a03b-b1c648146cc7 51a7c769-e107-4319-a714-1a15ff94e199 0bc52270-0d99-4e9b-8a9c-cf1bd9c165a7 c0afd6d0-4f12-4417-8cee-064172d51207 79053aa6-a382-46fd-b603-ac95a1f6156b 0d2eb6b7-ffd7-4726-b26a-88dd08b14ba0 e56e695f-d02c-4e5c-a0c3-d30c711ae255 77cff145-18c1-43a0-bdc2-fac60b50cb18 c5a97373-0acd-457e-8df0-36cd04e8486d eb17863b-748c-4d8a-ba07-9c91b570f2bd 6f1a3cdc-b270-47dd-a571-b5983f059179 28c37c37-8aa2-4339-a18a-434983280b75 e5106889-0758-498a-ab55-cfe3aab2bd76 471e4b4c-be44-4f09-add1-b2b9151ac6a2 80bac9db-afde-4d55-bb49-92acc196c2f5 4c09d39d-8aca-427f-b48d-2759bbd13062 6abb27dd-c2bd-45f7-9121-2921f991fdde 5c35c4ee-32bb-4f23-9dc2-d4c8a9f36482 fa0130de-967b-4008-89f1-8e7f8dd4302f d1e1d92f-69db-4df8-842b-a68787cd5ed0 a9037fa4-23e3-4b34-831a-9f3629c19acf 54ede0b6-f776-46db-86e2-44797d970ad4 f994bc2d-7e8d-4a17-a95a-eac2b2766bd5 f0a961ca-ca0c-4892-b765-a234b2e6d1d3 59a9a37f-e105-4171-bada-e2f72b0a3f3e 95b72847-5a89-4911-aee9-d2c2dbc7b3b2 2b5662ad-4459-4cc1-8599-2ccaa604af5b 29905c5c-a04d-4543-b3a1-a0ed6b7a452e 47efb619-bd53-4e85-83bb-cd046b9579d5 1692a7db-2b99-4a2d-b1cc-f16bd56c58cc 71c563ee-f194-4ac8-a116-c008672bdecc 7373046c-3697-4743-86ef-a1cfa87c7001 4a8958e7-d00e-4df6-802a-4c18b2c19f9f 89ef2a5d-2a1a-4d24-b784-039ea8af9295 e5a9a1a6-0189-45e6-8b95-eeda3a8cb674 661c0d04-9ce9-4348-b46e-968dd91375f1 9b4f4263-1d92-4bf1-82fb-7ea0b143123a d03b2e78-b819-4cc1-b736-ecf2ef01c3d6 349b5788-1f03-4635-812d-6b5bc837b038 d00915ca-30f1-4ba0-9b22-105d5d6d5763 4ca06492-41d2-476a-87f2-41e8570c3a42 1f5c895d-67d0-41c5-81ab-80d622a34059 1b971f41-9148-40ff-b12c-e9cb3563b43d f1f85769-12cc-4495-aaa0-f07ef085602b 64f0e140-de6d-4004-b785-48e524ed1921 6f7f3c6c-d862-4316-a939-7c10ca4f91cd 0751690e-bd11-4daa-93f0-99fa20aeec04 dd032a64-5808-4ba1-86cd-e795db929c7b c52d0411-6a5d-4d08-bb85-278e95021763 38f961a1-5de6-4c08-b5f1-af51452dad77 f5967384-cf13-4e21-b1a5-be2edb392d0d 47845f34-4613-4bb7-bf76-619e4bab4404 e7bcdd84-8d45-493c-b40f-ead9ef838d82 5f296c47-e527-4bbc-ba81-d4ba17049da3 0852936e-9921-42e6-a086-d918c036fb09 7d6906b4-a2e0-441e-a4f0-6115d2f5cfaa a0cc2f25-8abe-4ccc-bc4c-bc1e3985270a 338e22e7-0edf-4062-9d4d-45bdfbbeabc0 143a57d2-54d7-4564-8a08-5d19986a028a 5fe9944f-4bb3-4dfe-9e77-ef61a362b658 8b6e78ce-8cd9-4bdf-9705-617078d579c8 5e374d8e-f026-4f8e-94e4-8b1cf2791646 1cd5a3b8-711d-4a6a-8685-27aa5a969d77 3a1d0325-8701-44b1-930e-de6736ac6e74 cc761d03-5b61-447d-ac1e-10228ca1a86a 85eff1fa-eb9a-4a20-a0db-6dbbd40c6a71 98cca222-7739-43d9-982a-73d649f1386c d394bb0c-38a5-4c1e-af63-2cdcd4e91809 b4fde3bf-b99e-49b9-b333-cde03c05cba1 c863c27d-6320-434d-887c-290078775cad d467cc17-6e8d-4fed-9903-40e5b946b26d 16194c4e-0e81-4658-b5fa-ffcf25fafcfc a78a26bf-8160-49bb-9a7b-33f8d7596f59 51445a5a-0b07-4e03-958c-4139cefb4f53 3da54268-0a1f-471f-888e-11b26ef09537 34d07540-4599-4354-8c6c-e1e73fa99797 14494b69-3021-46de-80ef-4e907a3f6e44 694da092-81bc-4acc-a4f3-13e37e700357 d9d5af74-327b-41b8-b156-a9b0cdfee808 bd37d16a-96ab-4883-b2c1-f4e601048eb2 f4868bb8-8589-4f7b-a0c5-c038afe80afc d324b8c2-b704-4a48-816d-1d1cef86cd31 41c090bf-5871-408a-b8fd-0bf839b62bd6 7b1181f6-7e16-41c3-852d-cf06f32348c7 46fdb3c6-4dd8-44d7-9aea-b003e21c2581 8d4ccb23-fc1f-4231-9d11-7acc2e9e571d f5c256ef-85a3-4a0e-8e66-c0e76600d38c 7b4f9f3b-f236-4ff5-b188-1c438a3d9839 45f31eaa-fe47-4838-ba0e-5cdfc2e768bc e3399912-398b-4f72-96f5-bce844165059 e3421a38-aa00-4567-a9b5-95c1f9be8711 7f3846c0-c9b8-4548-ad21-2291aaafdfe6 90893925-b357-4115-a4c8-5ea0e82a1528 26c3072a-74ca-4645-b1f2-2456a05ed19d 6b9f478b-eba4-4612-990a-895453c409de 2b042bf6-4bd1-4a37-828b-4dce527a9459 9f798206-b276-4d87-89ed-15881181b237 08bd93e5-a11a-4935-bab5-3817f0e185b3 ba3f7520-1275-47b6-8ee1-7058f122e460 ea044498-4572-46db-bf54-ce155eefc3b6 a3b841b3-8f81-41ba-997c-38a84b68bd4a c3a1ee2c-0846-4b91-b3ad-26e3035d1da6 fd8f80bd-d9e5-4cb7-9d9c-da102d1139f5 5b4a5075-fc10-4307-8bff-61da9659ec49 a8293ba6-21be-48d2-bb23-d27027d3cfa0 bad0c758-8ef5-4a71-b9db-4b8f229235ad ad902f37-3737-440c-a1ca-ac4b6a7d0ef6 61ae5c43-1127-4265-8080-05d2834fe1b1 25ee805d-c3a5-4112-8f27-730b834cd3da 8647daec-ed8b-4bcf-b539-a991601d6b00 943a5e58-11a7-453a-9de1-29fb6e95d691 f64fda61-6e7e-41e5-ac87-044179800eca aa78eb13-10c5-4c19-acae-f519029104d7 1a56a8dd-0591-4526-9010-cc1a65af268e 018ba455-44e9-454e-9e30-6a38c6c8907f 7cba7be6-2ac1-4a46-8a4f-05f76873eda4 803b4740-2947-4265-b539-9c29b245c57d c8021984-0aa9-4dc8-bd26-a6689cec719d 7048e7bd-7372-4621-84d3-c0f4861f7c54 e352592e-b53d-4bc9-b52e-f8ea5138289d b8706f90-9e6d-4e47-87de-61c11ab3b217 e92f572a-e029-4469-93fd-557374769458 703ab8c6-a1c8-4e8b-8c84-47a06cbfcda3 c1868b25-f150-4679-8136-11521640b366 5894bf29-23f2-4763-a9e3-f7213fd00232 d8cc45f1-0f61-4058-bbe8-133d5fb17d78 25d7e958-9d93-433c-be04-5a985bbccf41 bb4c4ba0-1f8a-4aed-8305-7f498e61d22a c835553f-ebdc-4f95-a7ff-a7d4c126d5da 9659d4d7-ef46-4462-aabb-4babc53cb73f 315f74f5-5f11-42bd-8dfb-568adec0140e c31f8fa6-b60a-47da-af4b-9500eb9aa5e7 9677f991-3058-40c4-8e7c-4cab61ab0ea3 c63b2a32-3d98-45db-b251-49b7a05e4f09 f99d8c7c-0e67-48df-a9d6-3bfc9ec2d79c 5e4591a8-df3f-402d-984b-dfd6ed1246da c1b6d7fe-f3bc-4778-934d-fc25e6bbcd1e 732ae587-51a7-4fca-bae3-e38e32e185bc c693e74d-580d-457b-b6bb-2689ecb3a5f8 701feeff-4ee2-4b1d-bb50-f2ee524e9868 5194f82f-f3c7-4c90-9e5b-23236a5d9494 1ddee547-a730-41c3-b4df-9da2b7885554 b807dc96-b1ca-4654-91df-d3034fb7905e 09527e55-efe1-46ad-a68a-a6f421227259 4fed520f-4868-4f7d-9532-a4dc665d924a eb0f0f30-5ee4-4373-a48c-cf8b9e27c35f

## 3. Inputs and Contracts
Input: Profile metadata for Test-ChromeRunning.
Output: Script execution status.

## 4. Execute
- Write Test-ChromeRunning in export-chrome-profile.ps1.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "Test-ChromeRunning"` or `bash -c "Test-ChromeRunning"` depending on the environment. Expected output: success for ChromeProcessCheck(PS1).

## 7. Done When
- [ ] Criterion 1: Test-ChromeRunning is implemented.
- [ ] Criterion 2: Linter passes for file scripts/export-chrome-profile.ps1.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.

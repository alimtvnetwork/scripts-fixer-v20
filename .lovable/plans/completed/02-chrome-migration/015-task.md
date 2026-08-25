---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/export-chrome-profile.ps1]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section15"
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
  tests: "unit test-15"
  ci_cd_guard: "linter-scripts/check-powershell.ps1"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 015 — JSON Formatting (PS1)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for JSONFormatting(PS1).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Combine all data into single JSON. Add schemaVersion: 1 and source metadata. 9fb792d9-22d2-470f-a34e-45bb9c4f71ff 669292b9-fe5e-4cf5-bb1d-9095251aec9b bf27c3e5-d881-4f2a-b4cd-32047d5610ea 9b35fa85-faca-45e2-b8e9-eb758cbd3fab 0c3759a0-f302-4a9a-ba92-05e3ab4fc074 cd3b30ce-5381-478f-8bce-dd45a19e1078 3724b0cc-16f7-454b-a9d2-000165f709e3 030f4da7-4ca4-4b23-ada3-d4ab4e32d3bb f482372d-6e98-4ac3-a97c-c5917542753a 9243170e-f2cb-47cf-b0d3-1f392b8c8aab cae930a6-5baf-4227-a473-375ef6387bba e4402582-a701-4c31-b3b8-3e3fb55a80d3 dffc969b-50e2-433d-acb0-3ff92e7392b9 9678eece-8c69-44be-8e90-ed8d6e6f88a1 f323b058-9c72-4765-9d8b-b9011c2c7735 53ccc648-dbd6-4885-8ca6-34d5edd30b11 9a176b68-7825-41b5-83e4-d6ff14ec88bc 724c3fcf-90d9-4175-9e8c-bff37dbf9a28 c0f2f3b8-1475-4826-ab45-34e330d66b69 f5e898a3-46e5-41cf-9c77-d62509011e59 2c6a4dd1-33c9-47c3-81bd-39cc0f66fd13 bb72782f-3df6-4c4b-bb44-7bfb3c8e4292 3989c97b-b1a0-4057-942f-33f04316b3da 8b529aa4-1a52-4127-b69c-42be3bc08acc c50f5b04-4411-49b4-ae72-5dbc55b567e7 8fce2484-8634-48c8-b80f-d4226ebd936e 89334d5e-3eea-4abf-b3ad-938131536ed1 d0aa3ade-aa6f-46d5-afcf-c24db96e871e 5d201d65-b32a-41e4-9ae9-de3b84a14a47 5e2606aa-0f98-4de3-a7d3-3583d9ac3e4b 33636afc-633c-4cd8-9f4e-2dc100143ef5 7c8865b1-7326-418c-9963-382a47b5a74b f71e1620-a716-4af3-92dc-0b2051719399 3db3807c-1fd4-4aff-97b4-a4302072a7cc a0c55cb7-c2ea-43e3-a71a-9dbff61b7213 8764d963-7692-426f-9ecf-02af4d3a148b 9f9534dc-0bb0-450f-8a5c-501dcfe7a236 dc584905-c576-4ceb-b3cf-9e72edf12ddd 3334328a-0f17-4bcd-9999-46d18c2e25ef 7f1a946f-fde7-43eb-a6e3-f9e7f90ea985 34994b28-49ad-46aa-ac28-515208882517 313edc1e-b954-43fc-afd7-d8b8a8d8469c 1ae3ae3b-a5be-40af-9328-5853f395900b c287c060-e0f3-4656-8655-2e8863ec4f73 1bcaede1-9ded-437c-bf83-3a0d43c926f9 b1b19e1e-5f1d-4fa3-a432-a0138d53be2f 8db8a07a-f830-44f6-96ae-9998795fdb15 8808c460-f165-4d3c-87c2-bb16e042136c 6ead2f9e-67b5-45d0-acb0-8e18278d6cc7 46c93a08-fb80-4a4b-b1a6-449bb032b85e 659f8cd5-7c77-475a-8898-631a3b3b2ff9 369c6a0f-707e-42c7-833a-b76cf66b524e 75953586-0e73-4953-994d-4328f3c6b69f 3b0f05b6-64c9-4a82-a72a-efb14c059431 ec670043-ba75-47a3-a71c-23d48998ec55 532f8e62-7529-4110-bb99-c48f1c020d2b f07e44c7-6a54-4282-a359-c4f6e2d576bf acec1298-2907-4f5d-8400-254f7ad1df75 6838079d-f673-42c0-8e5c-44229593fd9c 2cc4db90-629b-43cd-8a83-3f97d36bf390 12e1c595-0819-4f0d-864d-676c43ed61c4 a86dccb0-3ca4-4b1f-b6dd-1144b4686791 a9396449-e59c-43d7-a7ab-e12edf664c6e 74982452-d440-4694-bf4b-cbaa79e5cee7 5de47768-fd07-45bf-9c87-e579bee69fcd 515355b7-157e-4834-8ecb-d3167c55faf3 fdf86c73-a9d7-41d2-b0f0-234d2243565c d51dc27f-b86f-49a6-9c6d-3d3dc5c13a0e 3175fe02-83a8-4e6a-b4e9-9ba87af251b4 f57d8bcf-9dd9-4aa0-80a1-79fe303de2b0 1f4c6bca-acda-42dd-a91d-ba58f03add87 e678c064-872e-4e30-80ad-9bf6f26f150c 17470705-682b-4625-8892-ddb989196ebc 23840ee7-4ec9-49bd-a1b2-dd03b49af9eb cded2b49-fddc-4e28-88ce-2537dee882cd c3fd96d3-88ea-4764-b24f-89a500c11206 ea75dee9-7357-4c6d-b7fe-f1d0835215e8 62ec9136-847a-46b7-809c-306f0a88b63c d2c21299-2273-49ea-a154-5de891f2d81d f3b27777-2271-4e70-b084-88ae0cd9b428 2e723aac-4d65-4136-b44c-883afbcd00ad 6559ebd9-0df1-48ac-b323-0e7935072d57 ba88da52-4eda-47c2-a537-7599c473e6b7 9bacf3da-c949-4e6f-8db1-ae7b7d623660 3ff3b759-8e86-41df-a52a-21ff30578a92 790b0f58-11c8-4827-9ea2-ccaaaabc3cca 310a50ee-d784-4776-b147-437c546df1d6 7a679cac-5431-405b-aafd-9ab19b966db3 43007ecc-914a-41d5-ad8a-1173227fdbe3 773e7f8f-9e84-4922-93d6-1e3c3657d2b0 61d1d1d2-0075-4dc8-b461-a5273ae001b3 e4aae059-848b-495c-88d8-c216717661da 7721f2fb-32e0-4220-8a71-03e365f33f20 251c929c-0083-43f4-86fe-9feb29821462 a919f22c-b1fa-4bb1-a569-681cdc9a1fce 6bdd8ecc-3117-4d68-8612-fa174e06c289 d7504c6e-4910-4041-9b83-14c50cc511ba c2fdd26b-0216-408c-8bf7-1a002010d8eb 11f4237b-c0d8-442b-a843-8e8c79e5f93f 4b59a206-b88c-42e3-bd3e-86dbdc5d3e2d 3dd6bfcd-de6e-443e-b477-d868a8b902d7 5a9bf224-04bb-4ee4-9d25-d5c0d0302b63 77806089-d041-490e-9027-9c6bbd0d0cb2 09b66ed7-4312-4a34-9b01-b175b4e94aa0 e6546ece-70d5-4252-ad04-61d2b471b7fc 1b44dac6-a963-4f95-9d56-a57b65d0e163 5e58f7ea-c2d3-4437-a601-c19be37ebe28 1e4a3b03-c43b-48a6-a846-88ae60c09fce cfd0bb2f-88ee-4951-b1a7-b2201ab48583 ef9b3186-78f3-464c-a298-1dc9d10c6fee c9caf773-2b5f-4b11-9b5a-60c9fb0ce73e 8b9739f7-6924-41c1-b05d-823ab0e1be8c 480d9ec2-54c2-4d28-b724-7ed1dab9c294 18b0421e-db4b-49fd-820b-04d9ca4ba541 15d849ad-2580-4070-b9b4-5b9dec7b1c25 17165f16-803a-45c4-972a-bb1def223aba c16b51c4-1897-4016-8af1-487845116793 ed8b912d-ec84-4317-983f-53ccd61d439f c5704675-0683-49f7-981d-d091b1a30431 a8f2cdd3-e50f-46ad-9571-4ecd1c396a0c 34d286a8-5c4b-47cb-8610-92bff2783445 8984527d-c416-411c-8355-bd98626006d5 80dc4451-8568-47f5-9f54-fc4b368db827 4d1004f6-1f87-478f-874b-fa062ecd084e a55b95b5-1c8a-4470-9a25-1964ffb3d84f 2f75bef3-ea12-4ec5-a034-d315f9880338 d31e91d9-5105-44d1-bf2e-219038b60722 37ffcb2f-0e96-4890-a3a1-2b3d362439b0 7576d509-343e-4b94-b849-25d270e9df37 c10a26e9-b67e-4942-94ba-ef5df07e6f9a 4eddefd6-c281-42c2-942a-ae6d6e463d59 c727784a-d889-4c0c-90d6-c2506230189d c96d0a7b-5adc-4466-90da-2db92834ca1f b4b2a905-c06f-42ed-b95a-b9b28d9711b7 ac9b3df6-6894-4104-bb87-76c553c39f78 8adf3175-6b08-452c-92e1-a24cbd0c0700 1800b029-b972-45b1-bf27-5c2f4572332e 17ef3fab-5dd7-4de5-9a4d-597e98a1839f a6be6a34-4f50-4e5e-9904-d809995e121f 544ea973-62b1-49c7-8b8d-bb7f149ab638 a31ee835-a7a7-4cd6-b833-76956b30e83c 51efe24f-72b8-4b4c-9605-cb186ca78eea 18733746-eda1-452c-a313-119c98e4a663 03adc9e2-3fe4-4e0f-896e-3ed076c1176f c54c35da-b871-40e9-8ac7-87579807af71 a43032fc-e728-455e-b2c8-196077e45daf f169887d-3ae0-4973-be42-7d70aa02cf1f 25376308-d976-4a44-baa3-1bc2cdd58886 3d0fc6f7-d206-4101-a4e9-f3f52dd311fe d8704dae-b96b-470f-a758-34f0e9cad41b 1012b2f5-90c4-460f-93b5-58297191604a d47b6974-45ac-45ac-a41c-1c983547d87b 1e43b1d8-9b54-49df-81b8-a62d8f076001 93327228-283e-446b-9ae9-7efcc8eab761 601d4ab8-3a5f-43ac-8089-e5e92a6fa94d cf4a667c-5195-4419-a6bc-d16e3818a636 f022eebf-abfe-4bc9-b39b-ab052f4239cc ef618be6-4458-4a40-929f-4eeeeb058043 180a5f42-d743-44b6-86db-5e925e181b48 a537131b-02e6-4b40-a372-87bf4aac3ab5 2904275b-285e-49d9-8f82-a0370d928509 463cdfd3-65ea-4a9f-928b-7958d75f1d6a d279a1f3-31c6-411b-8491-a6579c972cb1 30209e2e-587a-47e6-afa6-7a312278b552 c52dacd5-386b-4d38-8888-5fef9360bb1c 728ec8d9-877b-4122-abcf-954b23e1cb24 4fd4e650-4193-4dcb-9086-8671d6622334 84d1e8a8-18aa-4c6e-84ea-5d69a01babb2 9f5f6be2-14ac-409d-b276-0fa1b15e340b bb63148c-5ecd-4530-901f-ab0f09ce3730 fe374109-01c0-4821-843c-279eff7e48c3 68c54299-2cbd-4fd4-bea4-c18a89ef715a ea88a0c5-4858-44d4-8ae2-344f6399d9f7 1609cbd1-5d17-4b01-90a4-b16abbe00a43 01e2978a-a70c-4b4e-92a3-32d24834eaf8 81d68928-7609-4c69-8e85-1615ae4e9a61 b56c77b2-d15e-4fbc-848f-26c6af8074b1 c7a7910a-0ca3-4376-a29d-7ac26ace0462 1aaa5559-00c6-4921-9b9a-e4b3c67a2fcf 109ed756-b172-4bc4-9f2f-a6b7fb1c9505 0fef93a8-9dca-4afa-8ce6-848d9e9ae6f7 02f6d3fc-1418-41e9-8860-6750dff95ed8 22a738f8-0823-470f-bed1-5e40bda943de b0a5ef52-215d-42c1-a4ee-0f8031ae0f6c d7a4afca-4f5e-4dfc-ad60-290e947bdd01 bbdf0e32-4f5b-4da1-88b4-256fb6abbf7c 0103ac4e-6c4f-4fdb-b9ab-405d710fbcf1 d27b9e26-c390-4ee4-b649-5dd91de2eeff a22b2bd6-11f9-4503-8ab8-2e716e2d60ef cb805190-8166-4440-961a-987f57cbade4 4d648324-d3dd-4a2c-aead-5627ab396fb5 f7938842-2bfa-4cf1-a23d-0f7cabfe5309 8f5f8faf-32ca-44bf-a803-466dcd1a4d57 09eaf4f2-e5c1-40b5-9792-492b472e8396 96b5e74b-6931-4655-af76-265118b3d59a 3aeec002-f00b-45b7-abf9-59bcc90318fc dadceb95-a071-4395-b82c-eb03068c3d1a 66f24427-5338-49b5-8e24-f1a69d293779 93d6a809-620b-493b-a97a-2b073bb8a0a3 3ef120a7-cd04-410a-9c49-d77b9c2385c6 7fd1afeb-0f74-475a-be21-22b6f6a51624 127fa51f-228d-4111-af99-4c1557589c7f 783207f1-fd70-409d-aea3-b524da9af0be e6a76e16-7605-4258-96b8-2d8c763d3763 77cae13e-b177-4236-8c52-afe5ae84caa7 bff22de4-b51f-401e-888e-44bd618ee24c ba2f0cc3-ab1d-456e-867c-cfb1c99c41b1 987416e0-54be-4c0d-9eb0-dca37145317c e9bcdd75-3fbc-4409-80e0-628395af04f5 780520dd-6555-420a-bde4-eeb5291c1180 14c4fe59-913e-467e-b5c4-795ce09e17ec be50901f-3b20-4f8e-8a67-ad26b5d7f787 62ba0cac-ad72-4039-acdd-f96332c77990 fff88cab-f0de-4d0c-a138-30792e277e65 44de5c2f-205b-41c6-aeb6-c2d5de7d11f9 35d28f46-4bb5-4e3d-9ac4-7eee1da6368b 5b328ae5-c2a0-4f78-a6ab-ab5388db15cb e9d9a0aa-ae42-43f1-9492-ec53102107f9 2528b9f8-6fd0-4c28-a522-1dec2f5f8de1 4a7ff5a0-7ee0-47fd-a7c9-1463a645dbd2 856d9690-7d79-48e4-8b4d-051e706d7ad9 659ae41d-e918-4cdf-9715-aac3322f8d91 4be31d32-ad02-4737-90e5-fd7f1a937156 f734b327-d324-4582-b3bf-483cca0fcd99 a3d52023-f668-435b-a214-e59630ddffd9 9e240044-222e-43bc-b105-3bb10026a82c cb6c9b3c-d1fb-4bc9-9cf7-7424ded37538 f018c76d-e935-4b18-a84c-f9840652b2c6 edcc4e7d-5a7d-4313-ae6c-35c966b85cc3 921e4e14-fe33-4806-83a3-48f1987e710f 480bc199-51eb-49d4-a938-9102f1a9ae15 6b12df80-04ab-4c65-8951-471acb19084f 24a173d0-e459-4f49-aac6-0498527f399f 9701a292-4a74-49b8-859b-998ad660a77d 7cac8e3b-d00d-46f6-a243-71ceb8314420 df77dfd1-78c7-4a6c-9d24-a4e883b06ed5 9cfcbf39-7355-46d5-a48a-6d1cbe609195 57eb930b-98c9-4cc7-a5f1-364e99afda70 06bdf6bf-a383-4d8e-adf3-18fd090df239 4b5bc756-ff63-4193-ad7d-b556cf53655c 1ee2d285-2965-44eb-9430-576cea33ab97 44146de3-1ee2-4814-a6e7-1cfaf39afb54 63b6ab5e-3efe-4587-a305-1f454685e44f 27137706-f036-454e-a9e1-6413a9098e08 e93673b3-8473-4c29-ae9f-396680f4fa46 7fa835f1-d967-400e-a0de-68006a282629 b0b7a9b4-6542-4777-bac2-a8585eed672d 1e67d748-d970-42e6-a570-51dd87e6396d da50cfff-ee80-434a-9b34-9327b584d04b f996ce71-c33e-42f0-8cdb-2462a3b61ac2

## 3. Inputs and Contracts
Input: Profile metadata for New-ExportPayload.
Output: Script execution status.

## 4. Execute
- Write New-ExportPayload in export-chrome-profile.ps1.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "New-ExportPayload"` or `bash -c "New-ExportPayload"` depending on the environment. Expected output: success for JSONFormatting(PS1).

## 7. Done When
- [ ] Criterion 1: New-ExportPayload is implemented.
- [ ] Criterion 2: Linter passes for file scripts/export-chrome-profile.ps1.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.

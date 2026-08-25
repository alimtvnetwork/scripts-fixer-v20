---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/export-chrome-profile.ps1]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section1"
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
  tests: "unit test-1"
  ci_cd_guard: "linter-scripts/check-powershell.ps1"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 001 — Preflight OS resolution (PS1)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for PreflightOSresolution(PS1).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Parse UserDataDir, resolve Profile (dir or display name). 8523b161-7ad5-468f-b5a5-e2b238b3f198 4a71cb13-6b0c-48ab-8152-ad273a63c089 33037d31-0029-46e7-8872-9f6da2dc1168 a09c8215-2669-4bf5-b4c9-87ab0cab1256 f651bf3f-dc48-4435-8fa7-5144318d97d3 e1a0bd13-b000-4674-bba1-e092ae6399c4 63e8642f-a918-4551-b31b-ce4fba5095ed fe0ad98b-ecd8-41e7-af5b-d2dcce24efda b58e6a00-83e9-4282-bc30-ed8d8c60ac47 a122e7b6-9e56-40fa-b7e6-e9637de2bf8d ec94f335-4a2e-4227-80dd-cba707acec30 83d709c7-e4f7-4945-a930-84e0323fe1cb 39e25656-ceae-4241-ad07-c747a05c0260 c915a0a9-1465-403f-8e1a-ef00e7083327 ac3ff595-a81d-4f8d-9377-0285bb260bbd 21f7c68c-1951-4131-b92e-1ee15c41fb70 b78d49c8-ebbd-4502-a4cd-aabd3dc32ad1 9b5c670b-fb81-40aa-a714-f9a0feed7420 73777e14-9bf0-4300-b2be-5142da30ce4a 0729ed1d-47eb-428c-9bb2-466c29817162 762aeead-74f2-4053-85cd-42eea7ae21e1 002d7049-9f55-4c61-9ceb-be1b3c39f679 924e5224-d853-402f-95d5-c8eea5000765 1e7887c7-5723-4bb2-8e37-df41970b3770 4f87cb44-2005-4eda-9b21-915f0ca73868 5aca6d52-0625-4cab-a3b7-125535b9f3ed c77e09be-bf54-4287-b1a1-9aca84c3674f de67381e-3ae1-4735-a681-237806c918c7 a906fd95-e2fc-4e67-9e2c-d00ee2c72e13 d856cfa8-c0f3-4aac-a3b3-25c4bfd64dff 5cb9f467-b62b-4490-b578-89bc942ae275 1104b147-e603-4fe7-bb47-90f81b06e2c6 9880428f-4a00-4fee-ac92-8372c399d091 ce45ccca-fbbd-4659-ba4f-39c507713cd8 bc4a585e-fa48-4f5a-8409-e16f285196e2 bdebe945-4f67-4b80-b333-aba04446c97c 204f2f8e-d75e-4ac1-9afe-a32d3ee3006a 12ca836b-d97f-44da-b4d9-79827c13277e 6bd66688-527b-4a91-ab29-ee055775bd76 f010a622-c2ea-465c-849f-6cabc51f21c5 8636bb3c-db67-4095-bff2-1c07892a8b02 4105c213-0813-44a4-aba2-b10b55e6e50e d4d65276-1379-4647-b3ca-441906f6d2e8 b55576c1-abb5-4e83-b109-7a4d703d416f 1530e3c0-4c4b-4177-84f3-9d19940762dd c13d5b81-40a1-4d34-9b3e-badaf877b2bd 3d8de9a1-82f4-4105-b673-56765ce9e2a9 c1a5657c-c7d4-4d4f-ac6a-702decca3571 46e07d7e-3c6b-491b-b447-c8bbebb85100 a1c84d79-28e4-4b04-a7d9-ee9623157eb9 d96c8068-7c75-49c3-8fbb-61725387a0e0 610f2219-e9e1-49ad-a94d-66b4fcf778f0 9224ed73-b3ba-4eca-82c1-b73eb48f0ad4 83639522-0674-42d3-a139-2b23fa989b91 01398e34-1c95-408a-ae32-9b30a20cf09f 11562f9a-2ef8-44bb-82a8-c7643576b7fb ca28e61c-c125-404f-9afe-a4972574dc10 d464d9a4-18c1-4aef-9ae7-e7d812b62bb4 3a84971a-4424-43da-9b53-5bb36ed949e0 7e2c099a-7480-4f72-a29e-9e3bd8a6466b 1ffaf6ce-bea7-45d4-a7e4-05649c8a2a95 4a59c2f3-7adf-4341-a49d-72f821640ca9 c1c42ee4-e96d-46bb-8f62-d29a971f87e5 a1d4d9f8-cead-4036-bde3-b3315e3bc39b cd98f97d-720a-4006-80a0-1cd6d0fa7726 f327dda7-b815-4ed1-9d1c-e647f55fb45c 0d09a128-0963-4381-aef6-cb0040eb420d 1f13ccf2-1fba-4e84-8ad5-cfc33f10305b 36b3936e-de5d-416d-9d41-1b292f0d5e64 2b6eeb38-66e1-409a-86ba-cbc0426ed394 ca1c526d-ef41-4036-afb3-1bab59f1aeb4 681dbdfd-3064-4b7f-9339-b70542d2cc30 0b28df6a-0a91-47d1-a3ef-e3b407903dd7 6f99bb3b-66e0-4020-91c4-2d9e0b6f472b d05fbbba-1fca-419f-b57a-db0c9a5feaf5 b3bfe3fe-b83e-47fb-b29b-186bddd7f790 25b32fc4-ec30-4475-8420-b52462c992c9 4f60558a-37cd-4c61-b2ed-fb73806094c9 d1d9cf4e-dce9-428d-9d95-b9686c110c5d aa3304fb-2481-4c3c-9e18-10993ad1e9b9 6a66e7c8-2e5d-43e0-b0a3-c3db07665f00 5e5e5037-c936-478f-a85f-46f5ec3861a3 71258b29-978e-4ee2-89d4-27df2240ebf4 845e12bb-62a7-4448-8c50-e74da5caa4d5 a72589f7-c770-491d-bd13-7684601a15f9 788e0e61-4d06-4a26-a5b6-f482ceea835b 52aec048-6c58-475a-a33a-5c9a08ee66f5 a80e69a2-09e2-4064-9fe6-4be17b9c5fec 939c3cf4-f31c-45b7-b806-6dfb218c34b1 b6af4167-42a4-4949-a07b-fa5613174af7 02e38075-f8b7-4096-9058-65d273e8ed9f 1673a60c-14b1-4266-a965-d4d4da1f825d 9d83c775-0cc4-496c-a6bf-7b2878da7ceb 30d71a88-e768-47a7-ba2f-8355ecf41190 2376b171-329a-4e26-8978-397af43629f3 56f91e3a-dcea-48b3-8148-c2bcd115e823 4620088e-267b-4d9f-a791-7e1e28e595b5 5b5e9285-1b82-40e4-a891-7718f9215bc1 9924f8fd-6c09-4d30-a761-ffd9ac1ebde8 f6e6de17-f763-4134-8907-a440d30d1035 c7da741a-7f29-4220-ac7d-741bc22b0dcd 29e2e336-99e8-4b6c-be8e-d1b46320a1da 96bf219c-da65-4827-934c-199189a6f886 029c20d9-26f8-41e8-a71d-bb9adfb739e3 2a11be37-52dc-4b0b-8e8d-ed7249d56cdb c255b9cd-10ad-46ce-a485-f80d4111ff24 461f7438-f220-43d7-ab9b-7736ec12659b 4bbf6b41-a6d9-4509-944c-98198306b1e2 d1173cae-430c-4827-b626-d7826cdee308 06c7b0f0-3c73-4560-961b-e1be80685c2b b51e57db-fa08-4bac-9bae-8a53b8dbf295 ab2b98ea-6699-4699-be31-4adbe451d401 e9771e2c-550f-47d8-8691-cb0c828b7c63 66932596-73ef-4ffa-bf56-12da3395d7b8 538e38ff-aeee-4336-903d-596a2de5ef50 f13150d6-b59d-42cd-8301-dc3da2bb3cb8 58213a0d-e318-4ff8-9f90-843f61fce072 d773f4c0-9815-4f93-a5b2-4354cbde643a fbf436d2-d00d-4778-9557-e968c2d7086c e944cd1d-a64b-4d9b-ab40-73bae5d65f90 fd2e9974-4dc8-4dbb-b707-062a0e424f0a a587c4d3-3a95-4f7b-8549-dd170d19d91b 0ae1741c-ae04-4063-a159-24fb555562b2 d49cb5cd-7a50-478a-a50c-c49ccbda660b 0205ed3e-52df-404d-b274-a793e307b018 63b1940a-d742-465e-8426-ac0a778e8b0a 27a051a3-e41b-4349-a966-bbb9c2e47e96 5d572f71-6577-482f-b852-a06668b32b90 7a108622-1b2c-4722-bf0a-135acbfb2de8 a46a05fc-2fa0-4ea1-97e5-8ca5e2c2b358 3357b0ee-f459-4e50-8ac5-9c9baed63b40 84b99132-58f3-46b4-8b80-2048cf493f46 a15a77b5-6cc5-46a3-87f5-42ef863f42de 7d99f7cf-6661-4c27-95d5-685974f36b53 38d2edf5-c9b6-4caf-a43d-43d5bbd76528 f606bf8f-74dd-4d5a-872c-33c9c3c5e6a8 4a25ae2c-6082-4acf-b449-8bcfdbb6d659 f283ae0f-d001-4e8e-a1e7-ef56ad63787c fb6e251b-09e2-41ab-8ae5-c0daf595d7fe a016bc5a-fda0-4044-a81e-0f42470c4c22 8a4a2c7b-fd39-425a-b6fd-07ff6625306e 129fc7c1-51e6-4e47-bafb-be1470ecc0bb 41440f44-7cba-43c0-a92a-661a9dca406d 1b3b90df-e73d-4f13-9e9b-f9a4ac90c121 c255200c-5b3e-4c38-9b03-737117ef70f5 767c1cf8-36cc-41d7-bbb6-90518d1ce169 ca500d6c-0066-4d69-ba7d-baccd3c52816 ab9de3cf-d3fd-4def-abc4-a7ca4b07f8c1 2f045f70-a34a-424e-b026-684cd1c6973a 620c9f86-6f87-4900-9be9-95c2cbda3998 068ca184-b40b-4019-963a-07e44791028d 9abcd24e-6815-48e5-b11c-a702008f9127 26156c30-3720-4ee2-a0d3-99b3ad567f56 96ea9ef3-b196-4da1-81c8-1a23be86e63c ef626c84-36a2-4dce-bbb2-cb77762b6c38 c32ec7ff-2036-4fff-96da-aad0ae748f25 121ad5d9-a5d4-4ce3-b160-3b1efe952910 ce0c9696-918d-43e5-b36d-bfc551112235 60952369-e0ef-449e-92fc-2d415a4d1c7e eacd8b04-7f7e-44d0-9a49-2286e3b98ed5 989436ec-fafe-4f54-9f2b-791803de8705 e4fe01fb-4389-46f8-8aae-0a34acd040af f4f8a936-8a77-4801-801a-849bc1a02fb6 df733982-34ac-47af-9fd2-3a42db76d49c 3892b726-bf18-4553-9f77-0ac21a33c879 1146572e-941b-4e90-af53-d9a1f01b1c56 f4989895-db54-47ee-a492-596860e5f867 49e45e5d-4674-423e-8aa8-a03591d7b613 55f5179e-ddf7-41d3-895c-1b3b6d714061 6ab78991-0b2a-42df-882f-4ae6c97d1a2b 78aea139-dd16-4080-b5c7-244279372d82 df11672a-aa11-4ed6-ac0b-ffde58e3fd05 fb51effc-b09e-4d51-9545-d2102a9e7fa6 f2f07f19-0fb3-41a0-b8bb-935f3e62d198 fd324c22-fb76-4506-85f2-1f7f1b8c7846 514ae8a5-1f5e-4979-b00d-8c100841f47a e8668d53-8abb-4862-b24e-0d83258d124f 3fb290ca-8ece-40c7-ad8f-b976a4b4eeff fd475f7b-4cf0-4663-8c37-125ffa971f7b af28a947-5f61-4352-b47f-62a379f149b6 b7b7b6b5-4d57-4a65-8a85-ffa1e4757698 f2ebf125-1091-47c8-b3d9-15c0c3fb0112 cd262950-06fe-4487-8663-9237b78dea00 4d3c79f1-835e-4370-af16-360bd1c27756 01085d7b-a331-4c4e-8bb3-08e95744bf4e bb3431b5-4cee-4293-adf7-d84f7f75d429 23c8c75c-73c5-4c2c-9fc2-7a96f9e6c547 6fd86e58-aa0d-48aa-a17b-7dca8a375030 48f5f4d3-fff6-4e03-b751-196286c80725 024d2e89-7d57-4d63-a6a3-e4494124c4d7 8132cd48-0eeb-4bc3-a5c5-48c40c0a104b 004681a0-f5ea-49f0-86a0-626e256ddee5 64f397ce-2407-4b53-8393-2c01aed16a7a 9b73ec29-aeb8-4381-bae0-0d5ab8496a01 6f62279a-6027-4123-9aa2-c9ffd4a96d90 4395c2e8-7cce-4a26-9904-83cb9fd75368 a25e9950-d475-49c1-a8d4-19dbb0de0017 aee835f2-595e-4c45-8613-97abd6f02e1a f1e87f69-6d09-4491-ac17-fee5b8957f98 c9e5adb8-8fc7-44f9-9346-04f544564806 ccb25aab-8ec5-48d8-8f62-1014d28c7611 db489d89-26a6-4605-8a1b-19c77d942910 bbb8b2d1-56d4-4570-9a4f-f8d7f1b5f150 ae0a112f-b834-4cbf-8a14-abe23b8ebcd6 59851816-de78-4006-b2dd-76fbe8ee877b 993b3e7c-c4a3-4b85-a9ff-ed096f997464 926e1e85-edfd-49d6-aade-2783040f24b0 27da18d0-09ff-4701-9a12-6f2827ebf073 cbc5f3ab-bba4-44d1-b1fb-89e3d36d7835 c4604977-27d6-4e62-a846-c76cd0dafddf 69262daf-506a-4475-a3bf-67222ea55840 107c63aa-2009-4ec3-b157-12fe8cd1787e 105bf586-c9b5-4b04-b436-bf7c91154664 6a80b37f-9dcb-47ff-9ec9-49f3ccc69e68 9795df17-e2fe-4fb9-a30d-a2ee52f28e75 c28006c9-594f-4185-89ed-26d824eff098 4488c2fc-f8c3-41ac-903e-ec925fb1a4ac ffa1b817-094b-474f-8905-98a914d52eef 36b10065-9976-444a-a39e-5099c3838acc 7c0a00d0-7816-4be8-917f-fbc6625704ed 87a2dc6f-0267-44ae-8d3c-307925f3272f d9195b0e-e0a0-4da4-8505-14a5abfe662e d0a48f59-d8b4-4f4a-9cd7-672c01362dd7 5c9ab865-12e8-4ed2-ad69-9835f982cdd1 88afbde5-f20d-41c1-a411-9be77c8d4052 b3e16236-4146-47df-83e6-0eebf05c2354 e4dd02c3-0737-42f6-87dd-a79e0c7cd07b 63a4aa1a-d341-49f3-a02c-cf48c15fa66c 3c96aaa8-84db-498a-986c-9f4376fec8ce 18f3e8b3-8c2b-4c3a-87d7-afd89442c154 2ba4e419-8c98-4c65-8f69-aa8063dabdc7 e3611f1b-1659-4494-adc5-e7344cf6fd78 da091b59-bb94-47e5-9348-f020b8c6ece5 77bd588c-28c2-47cf-b71e-0e3aaa620ae9 fdeb9329-0cd1-4f36-914f-2cf20caa53b7 ee68c62d-77fc-4289-94f5-e996885f6752 f8f4031c-1470-44b0-9f4a-057d4c99324a 91cf9d39-d77b-4cd9-b759-bf6cb8393bf4 df3502b0-fccd-4424-9307-ad940117a9f0 5193eb00-541d-492b-8d2c-0a9c117126ce fa6a503a-ffaf-4967-8fb9-2cf921e2e44f 1d0a359f-3ed3-4b2e-8b77-642bcd5c13e3 a19c4676-ed36-4c95-8f2a-0f51f5ab25ad 6d3632de-aea5-4a56-b0d2-8f42a5141ab1 7024f8a4-c844-45a6-94c7-0df785cffd0f 90b51a22-8b2c-4abb-a280-c8b02b499f46 3f48f398-d655-4b04-b684-6946cc2a1c7b 41a62385-b091-4687-9ae3-5956d361e002 0a995589-98c3-44f3-b1aa-d0567fd2b0a7 b6402758-8214-4920-b922-d66656ec6014

## 3. Inputs and Contracts
Input: Profile metadata for Resolve-Profile.
Output: Script execution status.

## 4. Execute
- Write Resolve-Profile in export-chrome-profile.ps1.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "Resolve-Profile"` or `bash -c "Resolve-Profile"` depending on the environment. Expected output: success for PreflightOSresolution(PS1).

## 7. Done When
- [ ] Criterion 1: Resolve-Profile is implemented.
- [ ] Criterion 2: Linter passes for file scripts/export-chrome-profile.ps1.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.

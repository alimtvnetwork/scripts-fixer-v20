---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/export-chrome-profile.ps1]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section14"
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
  tests: "unit test-14"
  ci_cd_guard: "linter-scripts/check-powershell.ps1"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 014 — Secrets Export Decrypt (PS1)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for SecretsExportDecrypt(PS1).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
AES-256-GCM decrypt cookie/login values using the DPAPI key. 6112006b-c0d1-43db-95ba-961582a59b5a 5997ba55-11fb-4679-a44d-9f0de80441a0 a0d5da3d-1ff1-4ed1-8795-4a944f4c2d85 d2f61c06-9530-4980-899f-530c3a73b602 548725c2-0977-4406-b85e-f8bc3c0a0bd9 862a1e26-1b72-43b7-8755-f55e67027b5c e4805d1b-55c9-4d21-b898-a8cabb7f8d06 a02a8bd7-ab05-48fa-8dfd-0c73c90f04df 50b125a8-c36d-46aa-87d1-b8d8b179849f 210a72e4-fca0-4fe0-b3c5-bce7b5d2bf8b a4bf9ac7-f979-4b59-af3c-358f56450007 b670e607-d1ae-49b9-89a1-c9ab5eb2d46c 07a2b0ca-e1d9-465a-b207-6e14986597a6 8aa05465-fc23-48a0-a926-c8cb0a0e44b5 a0cf94dc-6a2d-4bfa-8077-6e19aa9e456e 6e80f864-ba0a-496d-ac7f-6eb98ac38cca 84f8c41b-1cae-4198-a8e0-fa8f8e72f641 d7d460a1-63dd-4121-b974-dfdfc261f147 636c30d7-d9c7-4f14-88b0-7646243d32bf 0d4c230e-4dbb-45a4-8577-cbe66fc66871 a65c438e-bc46-44d6-af3d-face65ad45f4 d44ba85e-7ab1-4ca6-a144-241fc6865a43 c165baf7-feaf-4f77-bd77-fa3da82879d7 ee7d5796-8019-48ed-99ef-7c01440b435b 2430ec55-7159-4a39-b357-faf95aad4d06 d84b6798-e510-4912-a149-e2f5ac688418 94c25c1c-17d4-43c3-9b8f-18fcf762b16a 2d6e0744-479c-4452-a22b-417d25c21a46 0c15518f-fed3-4431-baf3-65071798df81 edec3cd9-676d-49e1-a71d-9f523677e677 788adbeb-c25a-4c54-834b-636cabeb0a78 9049aaeb-3e63-4fd5-84a0-7469eedb6d06 93e4f9ae-3d77-4e88-a9e6-f2fe73ba1f18 2675a794-1de4-4b48-a3ff-2df38bb506e5 5da58ce3-6a36-4d5e-b911-4b3841ddd526 3a8cda2b-f6b9-4dcc-aa79-e2f74af4a7a9 23de5add-5765-4b23-851c-8b7cc5ee0ca0 c6577ef7-10e5-4eea-aff1-75a0bbd6343d 48797ad6-50fa-49b4-b796-27555089c73e 5702d89f-1896-407c-9e93-fb1fe498b389 be01e6c7-9749-47f2-9aae-94739b2966b9 c02fb716-9cba-4416-b9ca-ddfd1f589e15 8ec90c2b-0068-44c5-a0b0-64d802e76254 6ea04e1b-e6c2-4368-8a91-df8edec18648 a1430ef5-5b8d-48c2-8b6f-3b8e59edf0c9 ac0d5131-68b5-41d1-b3df-47918e0d5c38 61022d72-7641-47b3-87ce-c37065821714 2e92898a-20fa-43b9-9ae5-c8b42e6a82d4 18374933-f09c-467a-a495-b860f05fbf68 eaec6788-8bb5-4e35-b17a-d6bd32a8edfd 42053784-a428-4917-a815-2b64be511915 092b883e-070a-4ead-a5bb-630921c5799d 0b7411fc-911b-4d59-8cd8-b9d9c4ebfc5a c62132e1-ebd0-432e-91b7-d2ae31f692bf eb8862e3-a139-4aa3-bcda-1f67e2fcdea1 dc7c4ee5-ae3c-4d9c-8466-791511a3d561 cc7c5d42-1505-4c7b-b083-9ac49eba0744 769c9d08-efc2-4c0e-adae-0122eecf6bd3 124e3ad0-f581-4116-9d0a-b0ffe87a9710 c2b591e4-f784-4ef4-8c62-909fbd9d86ae a9f2cf60-94de-4900-98d1-574dc6384e4d 00653899-a623-4318-b5b7-69f633e7de76 4cc5538d-6adb-4fdb-ad2c-629e0f753e82 b06323f8-6b6d-460c-b3fe-9ee1dfa8c87d fb6f6b48-09d1-4b28-892c-318a1b6a293c a81c685b-53df-4d34-8358-da19f394f157 0be6eaa7-ed8b-4a9b-a80b-c5d55ff1edd2 66fe0958-7dc1-410a-926a-dfc77b15e268 9bfce45b-50b3-4fb6-bdfa-eaf3796334fa 44ca58a8-7c9a-4313-aba0-b4d03c02e094 e2b677d4-8a87-4a05-97ea-94954f54fb24 b72eaf1f-84e8-471c-aeb4-e71983ea769b fd66b2b7-dcb9-4e97-949a-a29bb8b1a97e b10de223-7bd9-4580-a251-aec69fd51d77 a5087d60-b0be-4b5c-9d9e-a83ba5d2ea6b d484435d-d472-4313-9cb3-46d51be583a2 d4707999-a545-413e-ab6d-850fe995fac9 fdaa7a05-5893-4103-8f78-6d18dc6d2eba 7c378cc9-755e-4dff-a91b-8608e25e176f 29fc2e6b-afe5-4901-a7a8-2bb567bc2d8a c0b621d3-f1d4-436a-a2a5-b33d7e21e2f2 6f19236f-8b4a-4784-b9ed-59b4e8cf0470 99938082-dab2-4fef-b4d8-610df70f9cb1 3d7b0fc6-9255-4753-a914-fc91d4895eb3 111b60ee-10a5-4bd2-b4e4-fa9cf672318f 94f30653-e18b-423d-aba5-07744115d8f3 4c4295ec-4de8-40dd-90e1-2e3728553983 147acd98-7556-4762-bb5e-533644330a1f 471331a1-f2a2-4cad-ad03-2fc4fa84e951 ddce2ee2-d83d-4979-a12d-0f5cf4520efc f5975a5b-d00f-4b0e-93b1-f27c460ab52e fe65ab49-64a3-49b6-ac4a-a54b7c0c75fc e38add3b-1f20-40f2-ae2f-51da4c169ba0 a1a23b9a-ac8c-4706-9bd9-bf079c861c98 f83cb1bd-ffb0-424e-9d83-71a0750338c6 d52f2cc8-8d5a-4369-9402-7b8a92b12ef0 29930399-11d1-4055-ab52-7563c86123c5 67be8723-1143-42a5-ae21-9f3079878557 c5c9cbf7-145e-4d48-a6b9-32e379c7a01c 9b6187ff-6605-4b45-a090-65a4619ed098 4482d082-d20b-4275-a8d2-0e7ef86b894f 08cde6be-86f7-4325-8c3c-881f764b169c 3f955d5a-2163-475a-9d80-a0fb75895890 0f103f8b-3854-4f45-a7d7-c81d291164cd a92c9003-5d01-4b53-94cd-7b602ead58fd 754815e0-0579-444b-85ce-ee1c373f91e3 00f7c358-4375-4fe3-84c0-be875719057b 2c1d34e6-49e2-4e0f-bc6f-cab8be9c0490 1e2f8427-0c08-4486-8a89-9167e8bccc11 1ebd88fe-db86-4299-bb99-14816aafea78 60f366d2-3b59-45bb-9593-068280ae7174 7326c7de-c472-42bc-b2e2-901fb821e56d 0f6551c8-096f-4a6c-9563-3e41d5cd683c 8f78fdd5-84d9-4148-8eb1-06cdef82cb23 eabb8d3d-d05b-418c-b1cb-4ad8921670fc 5c669f0c-445a-476a-8640-252633d3755d 80e5fea3-827d-4168-bb27-ef7fba783831 dc4e434e-1291-42cc-8d88-5f8889810e8f cf8ced7a-d50d-43dd-8c08-14cd90a2068f 62467cde-0d1e-494f-863d-59ef266aa889 64729f92-f294-4b91-b3a7-b2c75a4bcd8d d0201adc-9021-44e1-95c8-1adc50bd699c 158749d2-5721-48da-9638-abf05381e255 c1b88c71-29f7-4a35-aeea-b8d47ca1247d 0cf55f2b-ed88-4d0b-a2ab-979d3a50a53f fdad7593-82fa-4ffa-8ff9-0ebe3a27163b 43068ce7-db5e-420a-8361-54069d2d7f5d 82567c20-88a2-409f-bcee-f5facb168448 0982b95b-29cb-4fc1-b8e4-229985e11793 0fd1688d-cd8b-423d-96d3-1af06cf7134f 527a66d3-dcc9-4671-83b8-8afc16d5cbd8 cc3c9dc6-a88d-44a5-b8f1-becd263767fc 216e7066-662f-44f1-bf96-87133e6ce271 fb1f3666-7c86-4408-bed8-e60770517e7e e8de173a-220a-4bf0-bec6-c7cd960573b1 654ef7ac-08f8-4a4a-a8c7-69acb8af9ecd ffb561a0-e25e-4db8-a92a-f7da5252e4ff 9a721ae0-a25e-4062-b800-0ceccf34186d 67a39fdd-ead4-496a-8dde-d33f0431ea0e 4b1abfca-7682-42af-b97c-0c8f54e0095b 9d0cbd52-6eb5-4b79-b673-1eba1f7bf6b7 9bcce364-38b7-48cb-9d7d-f473eb50ed55 2343e08f-8fa9-4ce2-8f40-6944b71944d9 ce8ac120-f9ae-4e8b-b48a-5e1a149f5e13 d2767e21-447c-4c18-a076-e6660f8f5845 e54f120a-70d2-4c37-96d1-6ec923efa8dc 2b9dcca6-1f6a-45ed-abac-b8536c3b3a3e 15bd4d0d-1544-4c79-9231-d2789d43948b ba2837c4-cf4f-483b-b054-7cacb90f303b 917cd295-7e96-4120-a9f8-07fe0d4dbeab 2b9fa84c-b2b8-448d-a355-2e9b19d45c7c a8712a45-1272-4ce3-9d8a-ac99efc80672 3f8901ce-7def-4aac-83ed-3e42312a5e6d 286be2e0-9602-4435-a71c-26301d781442 56c3ee78-79df-4fa9-abdb-889a3c78b7c5 9793e4e4-9d8e-4dbc-8e6a-8d06972252f6 966ffb9b-4b57-466e-916c-52124312926b 349c7d71-3c14-4074-9caf-16c40a337193 f40f2964-5c70-4643-94bc-25a3065aecbe 6f36f5a0-eff2-48ae-934b-2313e6eeaf06 532ad4c6-8983-409c-ada1-d9f4412cad63 b53ac215-855a-4348-96b6-f7ceac8198c7 654c117a-f3bf-4cc3-beaf-1088d636e154 8ba6b8e1-7866-4818-89e1-7c5c27d6dec1 19f7218d-9569-4204-8bec-c480fd5f12c8 9052d037-bf8c-4fb8-b37c-22cb83c8c42d c85f5bb3-74ae-4917-a37a-faebee7a7c93 43a27410-fb8b-4c9c-874e-d554b066a0aa ccfaf191-b59b-45d0-a236-66ba89afaae0 c31b3d5e-50ca-4d53-8c9b-ecd8534c9f1f 250ff068-e6ca-451c-b0b9-84387809a234 5e13d042-5754-48ae-9a70-5e80743bf84d 7611110d-0b87-47cf-93d1-cdce2078a804 809bc659-a311-45d0-a100-2ee6fc79cca5 5c1acff3-4485-46b8-a792-5b72180dc8e0 c97abb49-602b-483b-8fa1-1255d15a5009 ee3e64a6-8a49-4043-aa1d-a7b88e10aefb 7998c779-b6e8-40f0-903f-fcb356c7ab1a 870c0d1b-5f8e-4437-8c68-62ad120b1d72 112ed0e1-123e-4b17-b594-3ca19564acfa 904a5cff-2076-42bc-9b1e-5749283c6f66 88676f45-d7a6-4d8a-bf69-29f0d38f8cb6 ce283dfc-baff-43af-aad1-193d2c6691aa e05edd6d-221e-49b0-81e2-ac143a0f4f09 f26a2e27-a7f9-4ced-b7c4-0b226c459f8f 46c305ab-2d5c-46dd-83b6-ec7b4eabb9df 1f7c5861-7f5d-4cce-addd-8a53eda818ea bb60f047-1baa-4e91-a2ff-b76a5e0570bb a50feaff-81f3-4045-90df-5dc8c87ed3dc 6d0cc72b-ffcb-46a6-9f5a-e3153ec96224 8dce4852-3e16-42c8-92b0-cfa9fc55046a 0eccdcce-f38c-44e9-8caf-9ac3043fd866 36934c64-5b3e-4479-8c52-87f2b9d06936 56ef6f66-e985-4cef-8f5b-eb82cf5d18c5 52c1d3b5-f51a-40eb-8ea5-43d647f63946 b5d769b5-0c5c-4b53-9dcb-9b8ed0e11dcd df05a060-def5-4db8-8089-88b6b84b81fa 674300e0-7540-4eb4-ad66-63dfb3314ce1 ef2c4777-190f-4d30-969b-f40f6661687a ca4a98cc-7198-466d-8d33-1b7e966f8ac1 5052f350-b443-4b8e-b758-3294bb0b1b30 80ccadad-eda2-40dc-a1dc-3ef24dafcb18 921a0d4a-65be-40dc-aa4e-a66ef5a002ec 0a69f9c4-e7ee-4469-8ad7-da1ae414a388 8e748fef-cb7a-47b9-b08e-fa8d41fc24d0 ead7e818-5b03-48d5-8656-184715ebf7be f203d8ed-471a-4e71-8905-03ae1c071237 08e2da6e-1e1e-48b9-a854-3495037de3ef 388c9511-a018-4998-a44a-31bff83f4392 e47acf55-0ffe-4792-9d84-c9d503271c57 a0fde106-dd73-45ac-b020-4aba9cafe248 fe89c6db-0a3d-4366-9891-06291968365d 853936e3-cb21-46f6-a8f1-ac3ac154529b b9af16f9-9af5-4e13-ae54-fdb1d623e9b5 a534d2c2-ef45-48af-85f1-6c508ed9dbf1 4b4ded05-0704-49af-8eaa-5a9048177901 9ba2dd17-82e0-483b-b52f-2c4e37259916 30c72bb1-104f-4cff-be7e-dfc54aada230 ff6d30b2-472b-4c25-82eb-b32cda31f82f 020c8a2f-72f4-4d81-b646-0214ddd7439d c529e9fe-44db-4905-9aa5-1bcd64ed875a 24c4efa4-fcfe-4a6d-936a-a98808770964 9c43aad7-d86e-4f74-81e0-e31e35e02a27 7cefb0c5-b88d-4af3-ad0a-bce61cb1b328 c639dac6-2ba7-4916-b3e9-f4abfd47647a 93475403-b4ca-4d3a-abfb-da10cfbcb7da 27cc2cef-3730-4671-b77a-a77169612c03 81d1ce52-109c-4ac5-b378-7630120c4e69 71f38821-52de-42b1-863b-3163595119aa c86ae010-443f-4416-96aa-5b33736a61c5 e1419669-f111-49a7-aeae-1ddb21966ca2 e41e5aed-262c-432c-9dae-a3ed21459326 37c27ba1-e429-47dc-8ebf-6eed9cba4ec1 1f7af34d-82c5-4b6f-8a2b-0f43f8f23986 ad812c00-5077-4246-a206-73d5d3596148 6bce2b19-3405-44ae-9df5-eaa91428f523 65c38529-d147-4105-b5c9-c29e5e71aa93 5b4e3ca4-3ebf-427a-9f69-db88ee981bf8 ecf6e1c2-6d7e-474e-a573-88f6fa965edf 5213d0ef-03cc-4372-a492-d3f792f71714 453003ed-9925-4e36-93aa-16f872c52b19 c0355f25-0749-4045-9a55-a5feaf11bf40 f58937bd-3693-4cc3-ac2c-0f34b8fc65e8 be3c211e-0efc-416f-99d0-c3aea2fa1cb4 03c00cd8-d316-4f74-90b4-01525e3b20de 722f6a84-6a3b-4db2-8300-db0d3402e35e 48faef38-77b9-4bf9-a11c-5ea34d58b976 1fed779c-d566-4d96-8f69-08236af9cf9b 1b9f8796-7a6a-4e02-966f-8030761cb082 caa6b484-bdc2-46ba-9033-e0f7ca3df53b

## 3. Inputs and Contracts
Input: Profile metadata for Invoke-AesGcmDecrypt.
Output: Script execution status.

## 4. Execute
- Write Invoke-AesGcmDecrypt in export-chrome-profile.ps1.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "Invoke-AesGcmDecrypt"` or `bash -c "Invoke-AesGcmDecrypt"` depending on the environment. Expected output: success for SecretsExportDecrypt(PS1).

## 7. Done When
- [ ] Criterion 1: Invoke-AesGcmDecrypt is implemented.
- [ ] Criterion 2: Linter passes for file scripts/export-chrome-profile.ps1.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.

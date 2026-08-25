---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/import-chrome-profile.sh]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section25"
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
  tests: "unit test-25"
  ci_cd_guard: "linter-scripts/check-bash.sh"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 025 — Extensions Policy Force-install (SH)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for ExtensionsPolicyForce-install(SH).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
If root, optionally write chrome-extension-force-install.json to /etc/opt/chrome/policies/managed/. 242dec68-f72a-45cc-a934-074508325819 79e697ee-eb93-4d26-9cf1-bfbfccf2f7f7 5861046d-8f11-4f55-96ce-152db9feb109 da000640-3bbd-44d0-a060-ee88384ceb6b a46c8586-2357-46e7-8c84-a6f861a46f70 cec4e0ee-9e67-46fd-bec6-3e29322f5c5c cfbdab93-f4e7-46ca-97d2-eeb54469f3fb 5bd13f99-b8a4-4f1e-814f-ec94aa23a508 04cf82ff-14dd-4b85-bc30-6be917dcd195 602592ba-1cf1-4ed1-8758-98d4a8cf652b 006ee471-1a98-4977-90df-787875b80b84 d16bb6ec-844c-4dfa-a544-f1d777b17c5d 449a864f-dad0-46cf-a92b-f4b138323e17 5ea0f873-fa35-4712-bcc6-2d5e5f1a2322 284747ee-dde4-437a-85bd-b04d519170d2 d19a8898-08ae-4235-9573-4bdf399211cd f4c0d7b4-cb14-4104-a603-7ffe2fe01b19 c9790eda-8dfc-4d71-947f-3e248064b2e9 e3360f04-7e86-4e39-a9ec-8ab1ddc9bfce 20f526a1-f134-4628-b2a7-068d80a95b65 f893d24e-23bb-47e0-9914-f92ecb66a1a9 914d2e1d-27dc-4548-ab6c-77ce6094fe58 29a33d30-7be4-4ce0-a6bd-f513895e3660 b6ba51dc-6aed-4c29-b5b1-694abca5500b 3221a8e8-9bd0-403b-a6bf-c1b69d42b61d 773cd69b-8fbb-4fd1-a46c-d7b4dd806bb4 6cace7c6-2a8c-4a17-9501-198ce4c541d3 953df0b1-d883-4244-a273-fc968c57a4a8 47aacae2-1099-45c3-a4b7-b02d3a67d7ff 29a8df88-36fb-4994-a622-911fd634b7c2 d22a115b-4d57-4ce8-af13-df6117462f46 b62072e9-3a00-4c5b-8eff-4f22e3ccc966 c646e0a3-a015-4daf-a807-3dc0d6db9a99 b8b5c234-79df-4ae8-b0c3-2429216aa5cd 3abc009a-6b64-4712-93a3-2af4dc60096a 7326ba12-4163-4b2e-b56b-8a79aef1464d da155702-5d00-4759-bac5-835b456fa556 516ff766-de05-4260-9418-ec7c7a0c9590 9d08641a-4890-43e0-9d02-a8cfd6f44ca0 20c1331b-4de1-4db3-af49-f9d752db870a c34421b0-fea1-49b5-9fbe-2aa7c7ad98d3 1cdb7355-6857-410d-ae14-bdba9688feee 20756e14-c7d8-4a03-9d25-50107935e476 d28c9c4a-2b3f-4b58-b6b9-029407f0eb31 ff44608b-9de0-4dbf-92de-1e2b5e5a3f15 0d1a2dfe-aefe-4f17-ac67-1bb8541f3b5e e4e37aeb-3179-4ded-a8ed-ceb7a05f29ca 0d3886f4-8da4-4ffb-ad9f-6efc41c679d3 ef4eebdf-dc8d-45be-8e23-70271928d685 7468280c-ac96-4e50-8634-33585ca46af1 d3f4b63f-ae3c-453c-a3d5-f0650057b2f8 4e84d458-ec33-4c7a-a0ea-29d2f78b9e1d 5611120c-2636-46d2-97e8-186998dc963d b2cc3d1b-0699-4a88-a4ca-673b96053f20 9e69e0a1-d083-47a5-b2d6-06d650e1e22a 048ada95-81f9-4ba5-b2a6-d2155f731de9 f6e414d7-d182-48c7-8909-eee0ea01cf7a e5141143-2f16-4692-8136-ce982dd9a6ff 3ef8bb55-beee-4a45-be20-22a86bf77755 fdfc3d97-25e1-4082-91c9-2ef46278110b 6535dc9c-d849-40be-868f-65f5c73f76a5 4c86d2d8-b80a-4834-b010-265de342b283 507e1cf1-f1dd-44a3-8adc-6b5634bb69b1 230d29ff-3bba-4b59-bf49-eb73c097d04e aab897ef-d708-4909-bbea-fbe943a36bd6 2aeb511b-5d1d-4eac-b23f-a0237e42436b 2a095756-9612-48f2-bf25-572d03c57b0b 0767ce04-f74d-441d-b9da-6a86718c73a9 fc6be6ef-078a-40ef-a21a-7b2e43d4a9e2 14b5707c-cd57-4ebe-910f-066285b4883e 84d35400-3e74-41ab-a8ec-0525ba5e1fdb 6f38eb1a-ba55-4690-b0f7-3f32ceff29c4 42ba6095-d1dc-4d41-8235-bb1501f8f271 c273ea6b-6c74-4415-831f-b3c258f13ed2 38b187a8-4f49-4cd9-810f-df22b344523b 86575d8f-32ec-41a8-b183-680c1282c155 220b60ed-4e7d-4f59-8a91-95c6010f4cee 9fbe1c4f-35ed-468c-934e-23fd89ab9979 4c63e3ed-d455-4ef5-8a02-de5ea0421632 615b2a01-6ace-45ff-a49a-2f14ff4e85ee 64e4b630-5c67-4156-95a5-a1c70fdd3d07 5b950ae2-98d0-4804-bec5-6fde040cf8e7 0ff657a5-2c18-4058-83f2-5081501b4577 c4b891fa-e1a4-41f8-967a-820102c57538 d89a8aa6-73f5-4c31-881f-26507cb2375d e4e3dd75-3fb4-43a7-8f4a-7f1230471aa5 1e40ddea-3294-4245-8629-d192a2c9da2c d0582301-304b-4201-aad3-466ad1843b01 7fb978ed-f494-4e3e-8450-559a6508e13c a7509a53-fea5-4bec-98d6-46b2cf4a5c56 c7960d89-3fca-4537-b4fa-7dd1ffd1639d c4f28053-1876-43c1-9fc0-2f21ff4a5956 161907da-df99-48ef-8fe5-f9314e3982e6 3d3dd1ae-4e54-4bec-b33f-cd587c762833 d033052e-c604-4721-8628-64ae6e174002 1b2a2f6b-fc83-473f-bfa8-54581593155f 8e5c1e35-18e0-4da2-a5cc-49efbc7ebe4f e4f52e28-7ac1-487a-9e49-f73047a215e8 48e04b53-1628-4fe3-8d1b-809f5271ab57 ea4db1e6-9e55-48df-b6d8-c5e4ed40639d dda4fa67-7cdc-4641-a43b-883e3de7adde 99e90c9c-416b-4f92-9df6-76f396baf120 7047ea9f-37cc-44d1-8a17-86a730f66dde 6c05440b-8048-4212-a500-07a9b75c8b9f ba34b18d-8a2c-401f-bf04-8939ad189756 ecb8a7d0-0d38-4a82-8c6e-1e71ef346a65 f099215c-a8b5-45fb-b4c8-cbbd10eeb887 2b4a9b7a-9b8a-4e98-980d-01e9079d6b16 34f6f6f4-01cd-4540-b9a3-fcafefc65359 d5a98eb8-e495-424a-b1ae-cb73e5567d7d a2423a88-bab4-470c-9d86-2a8782a8fffc 8cf675ee-36c6-4a01-b688-b0dc6d49db6f 9ca38fad-44f7-4548-89f7-6c376289e9af 13343a8e-8775-45a5-ba82-cb4c224bd0e3 d9d6abc3-8da3-434d-a331-d58da25c489d f8137c24-e155-44fe-b1bc-b41f32c9a201 f21277e1-9382-410f-a663-f24552822e42 ed9bf66f-17ce-48f6-afc2-1083ef15d10f ee3c05e1-77c7-4ad9-b714-eddf923789ea 68bd0510-b4ef-4e1c-8598-87d221d916b1 15e2a603-58d3-4347-a546-817998b486eb bd0d9210-253d-4776-aa30-cf1cd182d65b 0eea94a0-c37b-46d2-ae6b-fa601a7cac23 e7fac15f-3820-4594-a5f8-357d1195afe6 45b01e31-3714-4ce2-8b5b-86e3b3ed73f2 a0b16a4f-2212-446e-8081-a433670295ac 6f6b5076-98cb-41b7-a878-f99c01a10560 a04b9bde-33ea-434a-b624-341b657f3ed4 f530646f-52bc-49cc-8a9c-1d656e5d0597 f02e6970-2727-4efa-88f4-116e7fc59a0d 4112a681-a2bc-4fb1-911c-3058ccb5b09f 9973460a-1ca3-4686-8ac7-20fcbadab8f0 6e187762-e721-4a1c-a75b-9c270362d97a bc5a200c-3243-4d13-812a-baaa61107c86 f06f5b3f-5dcd-4d3d-b79a-8d61d176f791 62088720-fa64-44ec-86a9-8ac6210f7c8a 583b4f11-6009-45d4-8113-6cccacd4206c 161e533a-e8df-444c-9a8f-1301685b8275 1cc56784-65a0-43f0-97ca-7ad3cb9b1871 7d78f39c-cd64-4673-96ba-64af6b255050 1cfb61f8-216d-4f1d-b888-992a35fdb3cd 0e559444-f76e-4546-8ace-9e828b8f2725 c5fca100-123c-4aab-9835-d4eaaa666858 a1ca8352-7f69-4134-8686-367fabe41d8a 3ad595de-1015-4c30-a684-87d1f520d644 2472d876-a2a3-45dd-ab81-cb3ee1405156 e5497ff0-460a-419b-aa11-861c1295a270 d66bcf1f-f688-43a7-afef-d1a58c6416d8 cdd2d630-cfce-4383-be20-0527c925c41f 6254b609-02f6-4048-a2eb-7ef1cf2aa8f7 ea7125a2-a21a-4ff4-bafd-5c742d31d000 7dd5e364-1cfb-4e9b-9306-923dc6a1d299 aca7f007-ddb0-4b7b-8608-a78b3716f081 dd6fa1fc-4445-46c0-aeca-7aa7df057af7 918aa23c-a018-402d-b567-d1103b1e9d42 ed04f690-a6d4-4c24-864d-2319ac48488f b31eac9c-5949-4d7e-9b9c-f9d4210ce7c6 4f8cf4d5-a38a-4c5d-a624-f04c6debbb3a 35879852-eb53-40e7-9326-44cca84fbbce 156a5c0d-a019-45bc-bba4-1af388b9e83e faa717fd-8fd6-41eb-8a71-dc7547b5de4b 821b0a69-31bf-4b2c-b182-c419ba995923 8e84b230-5e7c-4ed2-9d62-4e36e95bd2fc 175892c8-3405-4b5e-8195-228fe7420b18 a19c4896-e2aa-4ed3-9d6f-7f6372e3007b 07c57113-d14e-4347-8fbe-8f00154f3279 76b978aa-881c-4531-a0fa-d2025bca1876 2b615691-ad59-4d03-b1eb-a5282bad6460 0e9f3c26-42cb-4296-9f49-4578321eadd5 c04e73b7-5a42-4349-9dc6-8368eb5e0b91 9273576b-7366-4f9c-a2b7-0b6e86b9cd25 a9dbfdd4-f71d-4e9f-9004-d2813bdaee6c a5c70105-571a-445e-8567-acef53669d7c 2121e2d3-e417-4e4e-9ffc-73f877548270 392cccf0-6b17-4770-bdb4-44593acca4be 45956908-86aa-415a-a6d7-0aee66ce9c13 326cdc12-668e-42c8-aeea-3512e6f8af0b f45016a4-2a4f-469d-930f-8d2a3bbf761f 07dd6cd9-f7f0-4acc-b29b-3765629b844c 27a97e1d-2001-4c80-9289-8adf2e369a3a 59d40ba1-e25f-4bb2-bee2-b0da8b77f3f9 510901b5-e66a-4143-967e-aaa49674a125 0d73d6de-b0f9-4507-abc9-81005822c91a b0308395-1883-48b6-a392-4b6d5b7d563e 485e3864-5bca-4689-b12f-32ae114738c8 03802d4f-0160-450f-8ff3-0a182f5b46bc 032f1e70-c3db-4a6d-8324-985cb4589b6e 03ea3cc3-da01-4b03-8280-cc5d4fa7357f 9d986381-772f-4f57-bb23-b1af8afb968f 74e3aac6-d7fe-4610-938f-898aa5b6d278 209dd1de-4e3b-4bbb-bb3c-e509b007b241 d9e0c262-2a02-4e48-980d-2cc55b101790 bab11d6c-e845-4497-bb32-2909b0f25cb3 3d3af386-eb45-4999-bf38-566df94b8c2a b51f66a7-e227-40e4-a7e9-6e68234849b2 a1285cb0-4e3c-41f1-9a8b-43b143d84106 97d8ed31-6c6f-4a09-ae9e-14bb2e30168e 0e9555ca-2a8e-4599-b619-f9771094029b 9f4a15f5-80bd-4cbb-81a6-c7c010f36231 651b5001-3b26-49aa-a589-819684c7222a 8125ea26-7b3c-4c5a-bf43-654ee83ac795 ce6b52a5-243e-4f2b-9374-f9c75aa70665 272b585b-c7db-4361-bdd2-7ef4c6a0941b a361f974-1307-4eb7-8943-e7bd505594a7 5df33a58-6cbb-43ef-a2f5-ff97a235f2c8 87b2cee5-c471-42e2-be83-c6a92a4c60d0 32f72652-de35-45ca-84d4-8b75b7d7be52 f9f96135-ecd8-49fd-b85f-0fc6b16e6a8d 4c6bd1cf-1b17-4eca-b264-bfad4884073a d1ed7245-9f47-4499-89e8-72472f00ed29 772c9bc1-1d65-483d-86f2-4b9784ca9d0f 8b18e0ae-029f-4d7a-a3ca-ebf036fc7760 8111e8ba-8f8a-4d24-951a-132d8c494aff c211c6c1-c1b7-4977-a7ff-f7ed22177c02 a9e7bb80-e8ba-40ea-96f9-dcb346e47ec7 a2ba86a7-4471-4a76-ac28-28b6582cc071 36da4c5f-b8e4-45d0-957c-2f849681b45f 765242fc-a1c8-4ffe-b504-8e59602dda67 05221fd8-b41b-406e-a51a-61de9ba2efc0 cfd8095d-d736-45b3-9784-cd91fc8b9038 26e7bff6-44dd-4cf4-af2e-6cbb828d812e 4d846385-2748-4abc-a4e0-4185ab45f91e c563dd38-164b-4127-828f-1d8c5f732c28 49a2cf97-0b28-4abd-b8b9-c910a908119d 5ebfb060-83fd-4678-a625-08fffcbe9110 3e0b8c6b-cf42-466a-8dd4-3eec5fa180f4 e2a6c023-9ef6-4083-8f71-41dc7cd99d78 84553b4b-0021-47d1-8c24-88d5ad8fa1dd bf1ca50f-66a9-4bd2-81c4-26b95022431a 4541e1e6-6b36-4962-aabc-35aa2f64a4b2 5978bedc-08dd-4d0a-b867-36e0080f307d 51d7ec68-ea8c-48b1-bd66-163fd4320f6f 036d9795-6d97-41f0-9df6-07df2e869e96 d158a962-f723-4e88-a292-07082173f1e9 32df5451-fb72-4592-870c-99711ad2139a e8546401-18e2-4025-a879-59359dcb529e 4e5265f3-4f01-4840-8dd0-6a95912b264c 16982fa3-6bba-4bd0-b286-423b36cc989c 8ec4c459-81a6-4d34-b701-5461db3dbd38 994f25e5-397f-4579-843e-469cb60a8c65 39b75fe1-f02f-4836-91e4-3268950c50c7 179afaf9-0a81-445f-8fd9-7f3c641c7ac8 2a177a7d-d57c-49ff-b833-161a998eaf71 b6563f10-a0a6-4f70-8368-9724314c039e 65dc9bcb-b875-4b55-9796-0892e8e2cec9 047ff63b-89cb-4b2e-891e-4c7cb2ce2522 8fa427e6-2b49-4120-b58f-903a9dd98428 025276ca-0fcd-47fc-94c3-700a38f1ccc0 6a0b9d4a-73ab-4691-8275-ebc356e9fe43 c821a2a3-d253-40d7-b706-52d9723812d8

## 3. Inputs and Contracts
Input: Profile metadata for generate_extensions_policy().
Output: Script execution status.

## 4. Execute
- Write generate_extensions_policy() in import-chrome-profile.sh.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "generate_extensions_policy()"` or `bash -c "generate_extensions_policy()"` depending on the environment. Expected output: success for ExtensionsPolicyForce-install(SH).

## 7. Done When
- [ ] Criterion 1: generate_extensions_policy() is implemented.
- [ ] Criterion 2: Linter passes for file scripts/import-chrome-profile.sh.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.

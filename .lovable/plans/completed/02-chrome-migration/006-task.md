---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/export-chrome-profile.ps1]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section6"
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
  tests: "unit test-6"
  ci_cd_guard: "linter-scripts/check-powershell.ps1"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 006 — Extensions Export Format (PS1)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for ExtensionsExportFormat(PS1).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Format extension info with id, name, version, enabled, fromWebstore. 4ef3434e-b993-45cc-bf4e-e68f222ebb8a 252e551e-edad-4e24-a09f-0f3ebb3e90e6 979ed3fd-3141-473e-bb0d-69c90766ab5c d8c4dc58-ac2d-4ff5-a6d0-0d5e69786170 c678a2df-7ad4-40fa-88c2-b978781ab34c dba81dc5-6457-412b-8ec0-4ca30e835529 777c2821-de9c-417f-b15e-2552211e6e14 4ba0a65a-5762-4e5c-a46c-124c457d0598 51396c3b-68ce-4d80-b08c-cf2d2e8d92c9 7bd9f84e-fc90-4c12-850a-6a71b5cfe055 bace01fc-6795-454d-8e55-16360957c163 91ac36a6-8c9c-4c53-8d41-eba66bcbcb61 51dce3cf-45dd-42e0-9c5b-147a7a407898 490656c8-0641-43dc-bd97-991ad55de8ff 0e668b70-9a5a-47ee-85de-85dc18b0928d fffc62c4-f291-4dcd-887f-04520e15a70c 9642918b-6ecb-4f2f-96ed-b13ddc583cd5 38a64cbc-bc19-4672-89c7-690ae4b2f306 6e9309b4-f301-4b04-ae80-1c0c73b7ecff b3056cf1-2672-4cf4-acd7-5ba15ba05cf1 d597c00d-1d64-4699-8bfe-c345cc7fffaa c94aafa2-bcb9-4a86-9500-29c01b2e5137 1a81b69e-bcbc-4aae-9ee5-ad3bbce47a89 3e5e2406-7fbc-4058-aede-dfb849d1c544 cfccb4f0-1ad0-4e82-806f-fb14dd22f1cb 34debe5c-866a-420f-87ee-b4f96a7e3422 da011c74-9ac9-4279-9024-aa003dd42bdd 55cce02f-b8f8-4337-8cb8-0165d0960ec1 64c2a8b5-6e9d-4ea0-aaf9-4cea593a83f3 edb254fd-8308-48e6-93bf-2c366b7ddd28 d4a6cd32-4c38-48a1-b362-89d15b726668 d584ec3d-21fe-4d0b-a807-ea48b5545d97 6912757a-f684-499f-b21d-ba8fee7d365e 6ad1744e-3abe-4d44-9a61-075ce4cc9e3c 7ffdc29b-53fb-4fec-bab6-a47534cd46ef e5736b4e-c703-45f9-a22b-24960cc154db ce59c524-726b-40f2-8ebf-f7659ff828cc a9e15c1c-22b7-48d9-a51b-1511e8ba2c7f 3eca9bc9-858f-466e-967d-a19bf74e4af5 093ce119-d406-4f3e-a8bf-9deab271f19f 27be65db-0510-4da2-83f0-65a2b8235599 c3f4827d-3977-4c76-a55d-05f4cdb39148 b12e6df9-bc20-4eb8-b135-41b9ba73129e b996630d-7f9b-46ff-86b0-1553cdf1c99a 5175c7a6-8cf4-4b43-b264-0557f690b9f8 cf080f29-3db9-47f3-881c-7ab9f341500f e21293b4-cdbd-49d0-94ee-5a1077dc8e19 659ede48-1d22-45cc-a248-9c94267e90b9 ed0257eb-b060-4636-bd87-410c4f8468ac e6986cf9-75e8-4fac-b027-39fa085688af d573e017-5c95-48ec-9bd8-7d6ff68ca259 75e24595-d4f9-410f-8a94-0bb4c0927982 ab4bf997-8bd2-440b-9d64-37a07cacc850 c92ae1cf-beae-4178-a9a5-713925d596ac 70e49da9-f94f-4042-869b-da6c55c8253c 1594fcf3-5ec3-493f-a3c8-0abc2d385bad 315bd4a7-eebf-4497-ae9e-8533baaf4e9b a085303d-e305-47ed-827e-b519861cbab3 a9daf8c2-caad-4d60-abd8-678419385a46 8ec2a06a-0c48-4ccf-9a00-793ca242cee4 24dac453-ac36-44ea-8ea4-3d806298ec73 21058f96-f621-4bdd-8535-853db5a015fa 7d6804d5-f649-49a7-be38-6a0979ea552c 1465fe6a-9b86-4ef6-a04d-fd27443a2532 089b1429-1cf3-451d-8fbb-408f25307c04 b5462cb9-4e45-4b8b-a8ef-d0e9fa4e957f 35fa0685-1807-4a80-8d79-df9f2044996a d3f0d210-5bcc-49ca-a8d1-085d290556a9 6da6ba33-2470-4110-9dc8-8c63bb8c6727 03ac292a-5c32-408d-893f-e8d2b49c293d 3a9c7ef5-1010-4685-875c-b5221fc90fe3 76a8c172-dc80-48ca-9776-2e6f58c9452a e42391e6-fb96-4657-80ca-c62690faf691 1c68c583-2a28-47eb-b0ff-b534d15e0a25 69d18f8c-b1b8-494b-9c35-a3a550e35cf4 73b29416-e809-4bd3-859a-359270945006 06402c7f-0ae5-4643-89d7-eae4f499be83 5cf0bca4-b06a-4740-af98-52d82492f132 8ba42e79-182d-4afe-875d-043cf4646200 987c02e8-e717-425a-bfb2-cf02738a9a3f 1461cde7-d105-4a8d-afba-687db56bf8ae 2c22aa9e-bff5-421e-b75a-8063a1fccd9d b4f813f3-99ec-4cf5-914b-d8e8369b2cce e6f2a9e2-b52f-494f-be27-483e4fbfd9eb be3e9403-fa83-490b-ae91-31b312982c83 5e14a904-1766-4843-ac51-7b5a6af7091b de9338ff-6e3b-4424-8ee7-535e9e048a26 97fa4348-2aba-417d-9d00-b66a9258bf2b 21d30787-8f60-4768-8925-ee5c96a6dcf1 b8eec61d-fb21-4899-a48c-5d3601f566ba 7486071d-c20f-4f5d-973d-11123e422e8a a96563a8-5e8c-4152-9bb4-d00306655313 a12985c5-7a51-4b6c-b841-5ed63580201b 63900c3f-eacc-48fa-8998-ab5706b7e5a2 3ab5a838-ccdc-40cb-95d6-a52d092ff1d5 72fb531b-fbe7-4526-9f2e-d085f05fa4d8 2b54702d-a3a0-45db-8120-3b06206b3038 5fb3f921-d0f2-4ee9-8c0c-bce955fb9851 f75f4516-7b27-48b4-8521-3a7b23970791 6f1e6484-e183-4555-b5c6-104bfa852c09 9fb3c6e0-473a-4947-8f05-7d3df5777b59 81167f19-5bb8-49a9-8fdd-3c8891ee5713 2edb1211-3de3-4d41-be5b-c629d4aedc99 186084f8-1451-4e57-ab49-559be12d4448 2f6dd4da-9b34-4daa-9d7f-2037dc78c417 2a06a07c-c61e-413b-bcbc-dc58d7ac0a88 72b4fd7f-1399-4ced-b67a-71fd5be8205d 36aa3682-5c7e-4bd4-b100-7216f2e5a2bf 582a098f-0aea-44fc-b0bf-735363e5b32d 1e2cbd44-9881-4dec-be24-cb2eee4b5d15 2eaaa3db-2835-4250-bd39-e7fda1c657d9 20f09387-c950-4bce-9087-4e3bb31eaee2 5fa37878-dd72-4522-b0b4-8b92b0cb4f19 5ca2075a-6e2e-498a-bf1d-aa06f34d4844 24c73572-a4d1-4b7c-9663-f7ce16eabec0 19df9356-550d-47d8-afdb-5b1abc11f670 1a2367f1-f649-4258-ab02-b12cac1ba429 967b7f39-0fed-4ab1-be43-6eb046ed8cf2 3b7214dc-6263-449b-816d-e762b0a36149 60280614-3fed-47b5-ad32-43edd073d089 18e12b67-a398-42ce-bbf6-928d1e7d1c97 d73b4e1e-c92a-4295-8ce1-3e08ad1031ed fb79c68d-5ea7-4407-8dde-4578b70dd901 2d69512e-285c-473c-8db1-9c8a02b9f5c5 5fd65c32-6189-4d9e-8b6f-df7885b11750 3d2c444b-457b-44cf-9e37-64ceaa9df68a 6cefe9ef-e913-4c6e-bdaf-f9f915bac449 9dea0828-77e2-4d74-8cd8-c91a6d892b8c f4f2e7e9-ff02-4d9f-b6d8-0078a29cdf0d 3d712e44-3da7-45d3-8c2b-7c10be72931d aba25b3d-1c47-49ba-bd16-3046d62b2043 44760f71-88cb-4b8c-8f55-994646419510 b0474b5f-cf0e-42ca-81cc-a4cfe7c42e6e 4b71485f-8222-42e6-886c-6a0a4fa4c01b 6156f733-ace9-4369-9877-dd05cb65a5bd eeb63a5e-1632-4ae0-8659-063cfdff81a0 e5cb8726-5936-420b-9fd5-74ff4bc6f4c6 a60a7431-df31-4329-af87-419413f8b49f c18e5022-4a8f-41ab-85d9-f6d0eb9acc87 2158b4ff-169d-439f-9f9c-74e611e4e7a2 f02b5309-1aa0-44db-98b8-9b079554f0f0 4a14f4ad-d92c-4842-96d3-031d87b81663 ab109a98-5432-4444-99b7-6139e8851ac9 4678fe60-61f9-43dd-8904-29e143ea9a70 14cd0f9c-9e89-46aa-9dca-fe64a8395677 e18aeb29-e8c6-41f1-a784-0af625fee511 87df4381-3625-4d9a-b6e2-613d5282cfce 1b931df7-8f82-4882-ba4e-2b9ec2f69a3e 0e4a02eb-4ee4-4a42-8206-b80a251d8493 bd94b41b-e81a-4ac9-81d7-28ba83e287e3 de2563b7-c70c-49b4-8afd-a232e372bca2 e80db665-b7cc-4748-8625-6970fe1d495d 7140761c-73ea-40d1-8cdb-28e2cfed5fe1 d653efc4-b6fd-4919-a30a-bf1ef8970b28 b5c5d173-3ffe-4f2f-bacc-904a858cf772 817fb258-6461-469c-b3af-e6cb680915a4 60fac331-b07a-4df8-a79e-27afe4b2de0d f3a94125-8841-4673-b457-e9a69fbb6634 8a336bfd-5d6b-437e-8dd9-79bd8add7f75 09638891-1d14-4108-bb7f-d42a2d293866 3941e68c-8da6-4a82-ac75-935ff6047c8d 24495102-8dbb-44d2-90e5-bd782c489503 9a5c1532-be0a-464d-9a7a-4f734f1070cf 9ce08a25-87e1-4709-afc4-3d66bf6d061f 0e32901b-af0c-462d-9303-7e78c2919493 407953e2-0c52-4b0b-b1b4-a141350111f3 1e677c40-3060-47d1-95d2-64957e692da5 dc42d301-d3bf-4dea-9c8a-d512027d60c6 54ab1314-85ff-4e81-8209-fb01269f5d17 7c9423f0-2fc3-4cb2-bb4a-123c5635c31d c6b06d62-544a-4340-9271-06644824d560 3dff84bf-e17b-46f8-b6c4-3b3f08b65c05 b975cec7-77cc-417c-ae17-c35db427e6da aec35684-3372-4f7f-9c64-fd315dd06731 5b50f810-625c-4b21-83d2-6cb911d6a8a6 e1363dbb-a837-4dfc-97c9-123053900e3c 1813584d-6d71-45d8-baf9-b6c4251680c5 d5ee4c95-604c-4cf9-a700-efcd598024a8 96db30ca-4c54-419f-8b83-074c0fc301c7 df7df483-86f2-4f04-adba-806165ece724 4478b617-d611-4b2e-a739-f4e9c128f2a4 f23d301d-26bc-42cf-8e4b-98bfdbe02385 c406a4fc-b0a8-4fcd-84af-3880b053de71 79c5077e-56d9-45ac-9a6c-80d499b24034 31563d2e-030c-4795-afdb-4af6521bc0de 48b84844-7b95-4d9e-a032-28aff2fa71c3 af792ca3-5e8f-4168-bf8a-4d254c5fcff8 eebbe988-d5f7-47b0-bf46-a6e5a82c8946 160dc5ac-1ea9-4aea-8c29-2a1620a0e2e9 f8769e2e-c11f-40fe-8fe8-2f0d6c8feed3 80b14a57-44e8-4bb5-b698-9d6c40d2ca92 8ed654c8-2b20-4693-9e80-215b9ab84660 0b1c2adb-9e6c-406d-869d-084d15474cac 14fc9e30-28f0-4264-b78d-c95f81294b84 9efc2ca4-da74-4092-82fc-c472bceaffcf 3a5c5231-bba8-4d6a-909d-dc6c70e0ed27 b6db9d71-aab5-4cea-84ba-3e4d28490117 46e7672e-bd2b-4aae-8788-7c776a647eae 99c47765-e0a3-4e42-beb1-348783d3cfa3 8e93443f-132c-4616-9156-bdfa2b5eecce 01903dbf-d690-412c-92e6-d97d12015fa7 7d287195-7ab8-42d3-a5f7-ce37617e4189 aacc441e-e337-4135-8632-d83cd1e4b10b 98547669-26c0-4e61-a228-1d321f727e15 edd11fa3-b80d-4e21-8123-181b2c036034 565cb484-988d-4e8e-ac8e-d6e0dec896e3 a74b7835-f4e7-44c6-9736-211748e01767 aaabd252-e532-415e-bdba-b144d912fce0 8dab283e-d314-430d-ad85-a7b722557b1d 18d4748a-5d45-431f-a884-0376d60a371f c6fbecbd-f581-430c-aad9-33869010d092 5c3269dd-7649-4e8c-a507-b368b996333a f19d7f0d-ce44-4dc3-bcbe-b5b82b09444a 30608be0-2386-4592-beb2-e6899f7e9e99 1aac23ab-938e-46ca-aace-67fa229a99ad 863e1795-3988-4bb9-be85-f052c0bf331c d51d0cbd-5a36-429d-9ebe-cb0194e85653 305d9f71-72f3-4db2-be5a-cb0afcf3c370 22b31568-8315-4b64-a3c8-06fd949148f7 5d209fcc-e0b8-4310-97e3-f86780ebb060 fa198805-918a-4dbd-a99e-8167c74bb36e b8f3db44-9125-4685-8d68-7ad13e1c6248 135d73ad-4c37-49ee-ba81-8f5617c8ab83 5cf98c69-f38a-4629-ad29-72400abab897 45caf157-a4fc-4423-acd5-099761abed4d c03c24e4-44c4-4867-97ce-4c9435f469ea ee60cbed-31f6-4ed4-b740-a0ddd83898c4 7e4ddc12-3ebe-444b-b64c-8bd3a87d5995 330502b3-cbd9-4666-b090-287a0cb52db4 4562eb76-f59f-4113-affb-cc6175dd620c a7abd69e-a8d5-4968-840d-f00b0cf45606 ec1b70c8-cc54-4fee-bc26-5ea77b360e9c 755d0487-c966-43e0-818c-3d9d00a3119d 1af1bc7e-f48a-4215-83d5-7f251f8b3a61 9535872e-62b1-430e-b9cc-14712ea1dda4 da005d05-b30c-4d9f-bbc5-ca41a99bb8c3 97bbbc86-c641-4fc0-a927-a499a6188baf 2acf6f39-f4cc-44c3-abd9-a1f800be62c3 b989f25c-e980-4a04-9c18-bd401b53534a b2b43dc1-311e-4645-a647-5bd7a6742427 dfb83fa9-9618-4d5f-99ff-1041c51e605d 7c59b9b0-82cf-47e5-8e35-3d72c20eccd0 173d27fc-899d-4491-8fe7-2876ef0845f6 1413e5ed-f8f3-44a2-9d61-f216f65ff49e 6c12adee-63b3-4b91-a193-ccbb8ad6274b a9bd4d0e-a49a-492e-9998-bca04209d532 c7408abf-bd8a-4a5f-b241-a515627b7918 37868f55-8b51-4fdc-857e-d23e2b35d1f8 0fdc951a-ea51-4263-b390-58aac99f5c75 6b34fceb-5c64-4449-8651-2f9635adca26

## 3. Inputs and Contracts
Input: Profile metadata for Format-ExtensionData.
Output: Script execution status.

## 4. Execute
- Write Format-ExtensionData in export-chrome-profile.ps1.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "Format-ExtensionData"` or `bash -c "Format-ExtensionData"` depending on the environment. Expected output: success for ExtensionsExportFormat(PS1).

## 7. Done When
- [ ] Criterion 1: Format-ExtensionData is implemented.
- [ ] Criterion 2: Linter passes for file scripts/export-chrome-profile.ps1.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.

//===- op_registration.cc -------------------------------------*--- C++ -*-===//
//
// Copyright 2022 ByteDance Ltd. and/or its affiliates. All rights reserved.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//===----------------------------------------------------------------------===//

#include "brt/backends/cuda/providers/default/flash_attn/op_registration.h"
#include "./flash_attn_bwd.h"
#include "./flash_attn_fwd.h"
#include "brt/core/framework/kernel_registry.h"

namespace brt {
namespace cuda {

void RegisterFlashAttentionOps(KernelRegistry *registry) {
  registry->Register(
      "byteir.flash_attn_fwd",
      [](const brt::OpKernelInfo &info) -> std::shared_ptr<brt::OpKernel> {
        return std::make_shared<FlashAttnFwdOpKernel>(info);
      });
  registry->Register(
      "byteir.flash_attn_bwd",
      [](const brt::OpKernelInfo &info) -> std::shared_ptr<brt::OpKernel> {
        return std::make_shared<FlashAttnBwdOpKernel>(info);
      });
}
} // namespace cuda
} // namespace brt

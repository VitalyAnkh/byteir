// RUN: byteir-opt %s -byre-opt="append-arg-types entry-func=main" | FileCheck %s

// CHECK-LABEL: gpu.func @Unknown0

module attributes {gpu.container_module} {
  gpu.module @unified {
    gpu.func @Unknown0(%arg0: memref<128x200xf32>, %arg1: memref<128x200xf32>, %arg2: memref<128x2x100xf32>) kernel {
      %c25600 = arith.constant 25600 : index
      %c2 = arith.constant 2 : index
      %c100 = arith.constant 100 : index
      %block_id_x = gpu.block_id  x
      %block_dim_x = gpu.block_dim  x
      %thread_id_x = gpu.thread_id  x
      %0 = arith.muli %block_dim_x, %block_id_x : index
      %1 = arith.addi %thread_id_x, %0 : index
      %grid_dim_x = gpu.grid_dim  x
      %2 = arith.muli %block_dim_x, %grid_dim_x : index
      scf.for %arg3 = %1 to %c25600 step %2 {
        %3 = arith.remsi %arg3, %c100 : index
        %4 = arith.divsi %arg3, %c100 : index
        %5 = arith.remsi %4, %c2 : index
        %6 = arith.divsi %4, %c2 : index
        %7 = arith.muli %5, %c100 : index
        %8 = arith.addi %7, %3 : index
        %9 = memref.load %arg0[%6, %8] : memref<128x200xf32>
        %10 = memref.load %arg1[%6, %8] : memref<128x200xf32>
        %11 = arith.addf %9, %10 : f32
        memref.store %11, %arg2[%6, %5, %3] : memref<128x2x100xf32>
      }
      gpu.return
    }
  }
  func.func private @Unknown0(memref<128x200xf32, "cuda">, memref<128x200xf32, "cuda">) -> memref<128x2x100xf32, "cuda"> attributes {__byre__BlockSize.x = 256 : i32, __byre__GridSize.x = 25 : i32, __byre__arg_ranks = [2 : i32, 2 : i32, 3 : i32], __byre__kernel_name = "Unknown0", __byteir_elementwise_fusion__, arg_offsets = [0 : i32, 1 : i32, 2 : i32], byre_compute_name = "PTXOp", byre_force_compute_name, device = "cuda"}
  func.func @main(%arg0: memref<512x200xf32, "cuda">, %arg1: memref<512x2x100xf32, "cuda">) -> memref<128x2x100xf32, "cuda"> attributes {__placeholder__byre.entry_point} {
    %subview = memref.subview %arg0[0, 0] [128, 200] [1, 1] : memref<512x200xf32, "cuda"> to memref<128x200xf32, strided<[200, 1]>, "cuda">
    %subview_0 = memref.subview %arg0[10, 0] [128, 200] [1, 1] : memref<512x200xf32, "cuda"> to memref<128x200xf32, strided<[200, 1], offset: 2000>, "cuda">
    %cast = memref.cast %subview : memref<128x200xf32, strided<[200, 1]>, "cuda"> to memref<128x200xf32, "cuda">
    %reinterpret_cast = memref.reinterpret_cast %subview_0 to offset: [0], sizes: [128, 200], strides: [200, 1] : memref<128x200xf32, strided<[200, 1], offset: 2000>, "cuda"> to memref<128x200xf32, "cuda">
    %0 = call @Unknown0(%cast, %reinterpret_cast) : (memref<128x200xf32, "cuda">, memref<128x200xf32, "cuda">) -> memref<128x2x100xf32, "cuda">
    return %0 : memref<128x2x100xf32, "cuda">
  }
}
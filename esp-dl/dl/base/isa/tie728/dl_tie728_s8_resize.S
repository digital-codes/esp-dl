#include "dl_tie728_s8.S"

    .align 4
    .text
    .global dl_tie728_s8_resize_nearest_2x2_c1
    .type dl_tie728_s8_resize_nearest_2x2_c1, @function
dl_tie728_s8_resize_nearest_2x2_c1:
    .align 4
    entry sp, 24

    # a2: int8_t *output_ptr
    # a3: int8_t *input_ptr
    # a4: void *args
    # a5: output_x_offset
    # a6: output_y_offset
    # a7: c_div_x
    # a8: remainder
    # a9: output_shift
    # a10: output_scale

    l32i a5, a4, 20
    l32i a6, a4, 24
    l32i a7, a4, 40
    l32i a8, a4, 44
    l32i a9, a4, 48
    l32i a10, a4, 52

    # a11 (0, 1)
    # a12 (1, 0)
    # a13 (1, 1)
    add a11, a2, a5
    add a12, a2, a6
    add a13, a11, a6

    s8i a10, sp, 0
    ee.vldbc.8.ip q1, sp, 0 # all output_scale
    ee.vld.128.ip q0, a3, 16

    loopgtz a7, 0f
        ee.zero.qacc
        ee.vmulas.s8.qacc.ld.ip q0, a3, 16, q0, q1
        tie728_s8_vector_round_result q2, a9, a14, q7
        ee.vst.128.ip q2, a2, 16
        ee.vst.128.ip q2, a11, 16
        ee.vst.128.ip q2, a12, 16
        ee.vst.128.ip q2, a13, 16
    0:
    retw



    .text
    .align 4
    .global dl_tie728_s8_resize_nearest_c1
    .type   dl_tie728_s8_resize_nearest_c1, @function
    # .balign 4
    # .option norvc
dl_tie728_s8_resize_nearest_c1:

    # a2: int8_t *output_ptr
    # a3: int8_t *input_ptr
    # a4: void *args

    # a5: c_div_x
    # a6: output_shift
    # a7: output_scale address
    # a8: tmp value
    # a9:
    # a10:
    # a11:

    # a12:
    # a13:
    # a14:
    # a15:

    entry  sp, 64

    l32i  a5, a4, 40
    l32i  a6, a4, 48
    beqz  a5, dl_tie728_s8_resize_nearest_c1_end

    addi  a7, a4, 52
    ee.vldbc.8.ip  q1, a7, 0   // load output_scale
    ee.vld.128.ip  q0, a3, 16

    dl_tie728_s8_resize_nearest_c1_loop:
        ee.zero.qacc
        ee.vmulas.s8.qacc.ld.ip  q0, a3, 16, q0, q1
        tie728_s8_vector_round_result  q2, a6, a8, q4
        ee.vst.128.ip  q2, a2, 16
        addi  a5, a5, -1
        bgei  a5, 1, dl_tie728_s8_resize_nearest_c1_loop

    dl_tie728_s8_resize_nearest_c1_end:
        retw



    .align 4
    .text
    .global dl_tie728_s8_unaligned_resize_nearest_2x2_c1
    .type dl_tie728_s8_unaligned_resize_nearest_2x2_c1, @function
dl_tie728_s8_unaligned_resize_nearest_2x2_c1:
    .align 4
    entry sp, 24

    # a2: int8_t *output_ptr
    # a3: int8_t *input_ptr
    # a4: void *args
    # a5: output_x_offset
    # a6: output_y_offset
    # a7: c_div_x
    # a8: remainder
    # a9: output_shift
    # a10: output_scale


    l32i a5, a4, 20
    l32i a6, a4, 24
    l32i a7, a4, 40
    l32i a8, a4, 44
    l32i a9, a4, 48
    l32i a10, a4, 52


    # a11 (0, 1)
    # a12 (1, 0)
    # a13 (1, 1)
    add a11, a2, a5
    add a12, a2, a6
    add a13, a11, a6

    s8i a10, sp, 0
    ee.vldbc.8.ip q3, sp, 0 # all output_scale
    ee.ld.128.usar.ip q0, a3, 16

    loopgtz a7, 0f
        ee.zero.qacc
        ee.ld.128.usar.ip q1, a3, 16
        ee.src.q.qup q2, q0, q1
        ee.vmulas.s8.qacc q2, q3
        tie728_s8_vector_round_result q4, a9, a14, q7
        dl_tie728_s8_unaligned_store0 q4, a2, a14
        dl_tie728_s8_unaligned_store0 q4, a11, a14
        dl_tie728_s8_unaligned_store0 q4, a12, a14
        dl_tie728_s8_unaligned_store0 q4, a13, a14
    0:

    bnez a8, dl_tie728_s8_unaligned_resize_nearest_2x2_c1_remainder
    retw

dl_tie728_s8_unaligned_resize_nearest_2x2_c1_remainder:
    ee.zero.qacc
    ee.ld.128.usar.ip q1, a3, 16
    ee.src.q.qup q2, q0, q1
    ee.vmulas.s8.qacc q2, q3
    tie728_s8_vector_round_result q4, a9, a14, q7
    dl_tie728_s8_store_remainder q4, a5, a6, a7, a10, a2, a8
    dl_tie728_s8_store_remainder q4, a5, a6, a7, a10, a11, a8
    dl_tie728_s8_store_remainder q4, a5, a6, a7, a10, a12, a8
    dl_tie728_s8_store_remainder q4, a5, a6, a7, a10, a13, a8
    retw



    .text
    .align 4
    .global dl_tie728_s8_unaligned_resize_nearest_c1
    .type   dl_tie728_s8_unaligned_resize_nearest_c1, @function
    # .balign 4
    # .option norvc
dl_tie728_s8_unaligned_resize_nearest_c1:

    # a2: int8_t *output_ptr
    # a3: int8_t *input_ptr
    # a4: void *args

    # a5: c_div_x / tmp value
    # a6: output_shift
    # a7: output_scale address
    # a8: c_remainder
    # a9: output_sar_byte / tmp value
    # a10: tmp value
    # a11:

    # a12: tmp value
    # a13:
    # a14:
    # a15:

    entry  sp, 64

    l32i  a5, a4, 40
    l32i  a6, a4, 48
    l32i  a8, a4, 44
    beqz  a5, dl_tie728_s8_unaligned_resize_nearest_c1_remainder

    addi  a7, a4, 52
    ee.vldbc.8.ip  q3, a7, 0   // load output_scale
    ee.ld.128.usar.ip  q0, a3, 16

    ee.ld.128.usar.ip  q2, a2, 0
    rur.sar_byte  a9            // output_sar_byte

    beqz  a9, dl_tie728_s8_unaligned_resize_nearest_c1_128b_loop
    movi  a12, 8
    beq  a9, a12, dl_tie728_s8_unaligned_resize_nearest_c1_64b_loop

    dl_tie728_s8_unaligned_resize_nearest_c1_32b_loop:
        ee.ld.128.usar.ip  q1, a3, 16
        ee.zero.qacc
        ee.src.q.qup  q2, q0, q1
        ee.vmulas.s8.qacc  q2, q3
        tie728_s8_vector_round_result  q2, a6, a10, q4
        dl_tie728_s8_unaligned_store0  q2, a2, a9
        addi  a5, a5, -1
        bgei  a5, 1, dl_tie728_s8_unaligned_resize_nearest_c1_32b_loop
    j  dl_tie728_s8_unaligned_resize_nearest_c1_remainder

    dl_tie728_s8_unaligned_resize_nearest_c1_64b_loop:
        ee.ld.128.usar.ip  q1, a3, 16
        ee.zero.qacc
        ee.src.q.qup  q2, q0, q1
        ee.vmulas.s8.qacc  q2, q3
        tie728_s8_vector_round_result  q2, a6, a10, q4
        dl_tie728_s8_unaligned_store1  q2, a2
        addi  a5, a5, -1
        bgei  a5, 1, dl_tie728_s8_unaligned_resize_nearest_c1_64b_loop
    j  dl_tie728_s8_unaligned_resize_nearest_c1_remainder

    dl_tie728_s8_unaligned_resize_nearest_c1_128b_loop:
        ee.ld.128.usar.ip  q1, a3, 16
        ee.zero.qacc
        ee.src.q.qup  q2, q0, q1
        ee.vmulas.s8.qacc  q2, q3
        tie728_s8_vector_round_result  q2, a6, a10, q4
        ee.vst.128.ip  q2, a2, 16
        addi  a5, a5, -1
        bgei  a5, 1, dl_tie728_s8_unaligned_resize_nearest_c1_128b_loop

    dl_tie728_s8_unaligned_resize_nearest_c1_remainder:
        beqz  a8, dl_tie728_s8_unaligned_resize_nearest_c1_end

        ee.ld.128.usar.xp  q1, a3, a8
        ee.zero.qacc
        ee.src.q  q2, q0, q1
        ee.vmulas.s8.qacc  q2, q3
        tie728_s8_vector_round_result  q2, a6, a10, q4
        dl_tie728_s8_store_remainder  q2, a5, a7, a9, a10, a2, a8

    dl_tie728_s8_unaligned_resize_nearest_c1_end:
        retw

#pragma once

#include "dl_base_avg_pool2d.hpp"
#include "dl_module_base.hpp"

namespace dl {
namespace module {
/**
 * NOTE:
 *
 * @tparam feature_t supports int16_t and int8_t,
 *         - int16_t: stands for operation in int16_t quantize
 *         - int8_t: stands for operation in int8_t quantize
 */
class AveragePool2D : public Module {
private:
    std::vector<int> kernel_shape; /*!< filter shape in [height, width] */
    std::vector<int> pads;         /*!< pads size needed in [top, bottom, left, right] of this operation */
    const int stride_y;            /*!< stride in height */
    const int stride_x;            /*!< stride in width */
public:
    /**
     * @brief Construct a new AveragePool2D object.
     *
     * @param name            name of module
     * @param kernel_shape    filter shape in [height, width]
     * @param pads         pads size needed in [top, bottom, left, right] of this operation
     * @param stride_y        stride in height
     * @param stride_x        stride in width
     */
    AveragePool2D(const char *name = NULL,
                  const std::vector<int> &kernel_shape = {2, 2},
                  const std::vector<int> &pads = {},
                  const int stride_y = 1,
                  const int stride_x = 1,
                  quant_type_t quant_type = QUANT_TYPE_NONE) :
        Module(name, MODULE_NON_INPLACE, quant_type),
        kernel_shape(kernel_shape),
        pads(pads),
        stride_y(stride_y),
        stride_x(stride_x)
    {
    }

    /**
     * @brief Destroy the AveragePool2D object.
     */
    ~AveragePool2D() {}

    std::vector<std::vector<int>> get_output_shape(std::vector<std::vector<int>> &input_shapes)
    {
        assert(input_shapes[0].size() == 4);
        int *input_shape = input_shapes[0].data();
        std::vector<int> output_shape(4);

        output_shape[0] = input_shape[0];
        output_shape[1] = (input_shape[1] + pads[0] + pads[1] - kernel_shape[0]) / stride_y + 1;
        output_shape[2] = (input_shape[2] + pads[2] + pads[3] - kernel_shape[1]) / stride_x + 1;
        output_shape[3] = input_shape[3];

        std::vector<std::vector<int>> output_shapes(1, output_shape);
        return output_shapes;
    }

    void forward(ModelContext *context, runtime_mode_t mode)
    {
        if (quant_type == QUANT_TYPE_SYMM_8BIT) {
            forward_template<int8_t>(context, mode);
        } else if (quant_type == QUANT_TYPE_SYMM_16BIT) {
            forward_template<int16_t>(context, mode);
        }
    }

    void forward_args(void *args)
    {
        if (quant_type == QUANT_TYPE_SYMM_8BIT) {
            base::avg_pool2d<int8_t>(args);
        } else if (quant_type == QUANT_TYPE_SYMM_16BIT) {
            base::avg_pool2d<int16_t>(args);
        }
    }

    template <typename T>
    void forward_template(ModelContext *context, runtime_mode_t mode)
    {
        TensorBase *input = context->get_tensor(m_inputs_index[0]);
        TensorBase *output = context->get_tensor(m_outputs_index[0]);

        std::vector<base::PoolArgsType<T>> m_args =
            base::get_pool_args<T>(output, input, this->pads, this->kernel_shape, this->stride_y, this->stride_x, mode);
        int task_size = m_args.size();
        if (task_size == 1) { // single task
            forward_args((void *)&m_args[0]);
        } else if (task_size == 2) { // multi task, use semaphore to maintain synchronization.
            module_forward_dual_core(this, (void *)&m_args[0], (void *)&m_args[1]);
        } else {
            ESP_LOGE("AveragePool2D", "Only support task size is 1 or 2, currently task size is %d", task_size);
        }
    }

    /**
     * @brief deserialize AveragePool2D module instance by node serialization information
     */
    static Module *deserialize(fbs::FbsModel *fbs_model, std::string node_name)
    {
        Module *op = nullptr;
        std::vector<int> kernel_shape;
        std::vector<int> pads;
        std::vector<int> strides;
        quant_type_t quant_type;
        fbs_model->get_operation_attribute(node_name, "kernel_shape", kernel_shape);
        fbs_model->get_operation_attribute(node_name, "pads", pads);
        fbs_model->get_operation_attribute(node_name, "strides", strides);
        fbs_model->get_operation_attribute(node_name, "quant_type", quant_type);

        if (pads.size() > 4) {
            ESP_LOGE("AveragePool2D", "pads(%s) is not supported", vector_to_string(pads).c_str());
            assert(false);
        }

        while (pads.size() < 4) {
            pads.push_back(0);
        }

        // Create module
        if (quant_type == QUANT_TYPE_SYMM_8BIT || quant_type == QUANT_TYPE_SYMM_16BIT) {
            op = new AveragePool2D(node_name.c_str(),
                                   kernel_shape,
                                   {pads[0], pads[2], pads[1], pads[3]},
                                   strides[0],
                                   strides[1],
                                   quant_type);
        }
        return op;
    }

    void print()
    {
        ESP_LOGI("AveragePool2D",
                 "quant_type: %s, kernel size: %s, pads size: %s, strides size: [%d, %d]",
                 quant_type_to_string(quant_type),
                 vector_to_string(kernel_shape).c_str(),
                 vector_to_string(pads).c_str(),
                 stride_y,
                 stride_x);
    }
};
} // namespace module
} // namespace dl

#include "rclcpp/rclcpp.hpp"
#include "std_msgs/msg/float64.hpp"
#include <chrono>
#include <memory>

using namespace std::chrono_literals;

class MotorCommandPublisher : public rclcpp::Node {
public:
  MotorCommandPublisher() : Node("motor_command_publisher") {
    publisher_ =
        this->create_publisher<std_msgs::msg::Float64>("motor_cmd", 10);
    timer_ = this->create_wall_timer(500ms, [this]() {
      std_msgs::msg::Float64 msg;
      msg.data = 1.0; // Example: target speed
      RCLCPP_INFO(this->get_logger(), "Publishing: '%f'", msg.data);
      publisher_->publish(msg);
    });
  }

private:
  rclcpp::Publisher<std_msgs::msg::Float64>::SharedPtr publisher_;
  rclcpp::TimerBase::SharedPtr timer_;
};

int main(int argc, char *argv[]) {
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<MotorCommandPublisher>());
  rclcpp::shutdown();
  return 0;
}

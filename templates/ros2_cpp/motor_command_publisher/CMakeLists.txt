cmake_minimum_required(VERSION 3.5)
project(motor_command_publisher)

find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(std_msgs REQUIRED)

add_executable(motor_command_publisher_node src/motor_command_publisher_node.cpp)

ament_target_dependencies(motor_command_publisher_node
  rclcpp
  std_msgs
)

install(TARGETS
  motor_command_publisher_node
  DESTINATION lib/${PROJECT_NAME}
)

ament_package()

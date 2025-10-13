require "test_helper"

class AgentInvocationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get agent_invocations_index_url
    assert_response :success
  end

  test "should get show" do
    get agent_invocations_show_url
    assert_response :success
  end

  test "should get new" do
    get agent_invocations_new_url
    assert_response :success
  end

  test "should get create" do
    get agent_invocations_create_url
    assert_response :success
  end
end

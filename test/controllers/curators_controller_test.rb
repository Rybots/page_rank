require 'test_helper'

class CuratorsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get curators_index_url
    assert_response :success
  end

end

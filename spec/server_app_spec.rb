require File.join(File.dirname(__FILE__), 'spec_helper')

# This is just a comment test

describe Rots::ServerApp do

  describe "when the request is not an OpenID request" do

    it "should return a helpful message saying that is an OpenID endpoint" do
      request  = Rack::MockRequest.new(Rots::ServerApp.new({'sreg' => {}}, 
        {:storage => File.join(*%w(. tmp rots)) }))
      response = request.get("/")
      expect(response).to be_ok
      expect(response.body).to eq("<html><body><h1>ROTS => This is an OpenID endpoint</h1></body></html>")
    end

  end

  describe "when the request is an OpenID request" do
    
    before(:each) do
      @request = Rack::MockRequest.new(Rots::ServerApp.new({
        'identity' => 'john.doe',
        'sreg' => {
          'email' => "john@doe.com",
          'nickname' => 'johndoe',
          'fullname' => "John Doe",
          'dob' => "1985-09-21",
          'gender' => "M"
        }},
        {:storage => File.join(*%w(. tmp rots))}
      ))
    end
    

    describe "and it is a check_id request" do

      describe "and is immediate" do

        describe "with a success flag" do

          it "should return an openid.mode equal to id_res" do
            response = checkid_setup(@request, 'openid.success' => 'true')
            params = openid_params(response)
            expect(params['openid.mode']).to eq('id_res')
          end

        end

        describe "without a success flag" do

          it "should return an openid.mode equal to setup_needed" do
            response = checkid_immediate(@request)
            params = openid_params(response)
            expect(params['openid.mode']).to eq('setup_needed')
            expect(params['user_setup_url']).to eq('')
          end

        end

      end

      describe "and is not immediate" do

        describe "with a success flag" do

          it "should return an openid.mode equal to id_res" do
            response = checkid_setup(@request, 'openid.success' => 'true')
            params = openid_params(response)
            expect(params['openid.mode']).to eq('id_res')
          end

        end

        describe "without a success flag" do

          it "should return an openid.mode equal to cancel" do
            response = checkid_setup(@request)
            params = openid_params(response)
            expect(params['openid.mode']).to eq('cancel')
          end

        end
        
        describe "using SREG extension with a success flag" do
          
          it "should return an openid.mode equal to id_res" do
            response = checkid_setup(@request, 'openid.success' => 'true')
            params = openid_params(response)
            expect(params['openid.mode']).to eq('id_res')
          end
          
          it "should return all the sreg fields" do
            response = checkid_setup(@request, {
              'openid.success' => true,
              'openid.ns.sreg' => OpenID::SReg::NS_URI,
              'openid.sreg.required' => 'email,nickname,fullname',
              'openid.sreg.optional' => 'dob,gender'
            })
            params = openid_params(response)
            expect(params['openid.sreg.email']).to eq("john@doe.com")
            expect(params['openid.sreg.nickname']).to eq('johndoe')
            expect(params['openid.sreg.fullname']).to eq("John Doe")
            expect(params['openid.sreg.dob']).to eq("1985-09-21")
            expect(params['openid.sreg.gender']).to eq("M")
          end
          
        end
      
      end
    end
  end

end
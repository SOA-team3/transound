# frozen_string_literal: true

class Token
  def get
    return apply_for_new_temp_token if time_difference_of_get_token >= 55

    TEMP_TOKEN
  end

  def apply_for_new_temp_token
    # Define the URL for the token endpoint
    token_url = 'https://accounts.spotify.com/api/token'
    # Define the parameters for the POST request
    params = {
      grant_type: 'client_credentials'
    }
    # Set the basic authentication header with your client ID and secret
    auth_header = {
      Authorization: "Basic #{Base64.strict_encode64("#{CLIENT_ID}:#{CLIENT_SECRET}")}"
    }
    # Make the POST request to the token endpoint
    response = HTTP.headers(auth_header).post(token_url, form: params)
    # puts response.body
    json_body = JSON.parse(response.body)
    access_token = json_body['access_token']
    # save the temp token
    save_temp_token(access_token)
    access_token
    # puts "access_token: #{access_token}"
  end

  def save_temp_token(access_token)
    # Modify the value of spotify_gettoken_time and spotify_temp_token
    config = YAML.safe_load_file('../config/secrets.yml')
    config['spotify_gettoken_time'] = current_datetime.strftime('%Y%m%d%H%M%S')
    config['spotify_temp_token'] = access_token
    # Save the updated YAML back to the file
    File.write('../config/secrets.yml', config.to_yaml)
  end

  def current_datetime
    # Create a TZInfo::Timezone object for Taipei, Taiwan
    taipei_timezone = TZInfo::Timezone.get('Asia/Taipei')
    # Get the current time in Taipei
    taipei_timezone.now
  end

  def gettoken_time
    date_time_str = GETTOKEN_TIME
    # Convert the string to a Time object
    Time.strptime(date_time_str, '%Y%m%d%H%M%S')
  end

  def time_difference_of_get_token
    # Calculate the time difference in minutes
    ((current_datetime - gettoken_time) / 60).to_i
  end
end

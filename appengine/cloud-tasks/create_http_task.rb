# Copyright 2018 Google, Inc
# Licensed under the Apache License, Version 2.0 (the "License")
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START cloud_tasks_appengine_create_task]
require "google/cloud/tasks"

# Create an App Engine Task
#
# @param [String] project_id Your Google Cloud Project ID.
# @param [String] location_id Your Google Cloud Project Location ID.
# @param [String] queue_id Your Google Cloud App Engine Queue ID.
# @param [String] url The full path to sent the task request to.
# @param [String] payload The request body of your task.
# @param [Integer] seconds The delay, in seconds, to process your task.
def create_http_task project_id, location_id, queue_id, url, payload: nil, seconds: nil

  # Instantiates a client.
  client = Google::Cloud::Tasks.new

  # Construct the fully qualified queue name.
  parent = Google::Cloud::Tasks::V2beta3::CloudTasksClient.queue_path project_id, location_id, queue_id

  # Construct task.
  task = {
    http_request: {
      http_method: "POST",
      url: url
    }
  }

  # Add payload to task body.
  if payload
    task[:http_request][:body] = payload
  end

  # Add scheduled time to task.
  if seconds
    timestamp = Google::Protobuf::Timestamp.new
    timestamp.seconds = Time.now.to_i + seconds.to_i
    task[:schedule_time] = timestamp
  end

  # Send create task request.
  puts "Sending task #{task}"
  response = client.create_task parent, task

  if response.name
    puts "Created task #{response.name}"
  end
end
# [END cloud_tasks_appengine_create_task]

if __FILE__ == $PROGRAM_NAME
  project_id  = ARGV.shift
  location_id = ARGV.shift
  queue_id    = ARGV.shift
  url         = ARGV.shift
  payload     = ARGV.shift
  seconds     = ARGV.shift

  if project_id && queue_id && location_id && url
  create_http_task(
    project_id,
    location_id,
    queue_id,
    url,
    payload: payload,
    seconds: seconds
  )
  else
    puts <<-usage
Usage: ruby create_http_task.rb <GOOGLE_CLOUD_PROJECT> <LOCATION_ID> <QUEUE_ID> <URL> <payload> <seconds>

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
  QUEUE_ID must be set to your Google App Engine queue ID
  LOCATION_ID must be set to your Google App Engine location
  URL must be set to your HTTP request target.
  GOOGLE_APPLICATION_CREDENTIALS set to the path to your JSON credentials

    usage
  end
end

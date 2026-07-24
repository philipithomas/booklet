require "swagger_helper"

describe "Members API" do
  let(:community) { Community.create(name: "Test Community", email: "test@example.com") }
  let(:api_key) { APIKey.create(name: "Test Key", community: community).external_key }
  let(:existing_member) { community.members.create(name: "foo", email: "leonhard@example.com") }

  path "/members" do
    post "Creates a member" do
      security [ { api_key: [] } ]

      tags "Members"
      consumes "application/json"
      produces "application/json"
      parameter name: :member, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          about: { type: :string },
          email: { type: :string },
          permission: { type: :string },
          subscribed_at: { type: :boolean, nullable: true, summary: "Opts in to receive emails immediately" },
          quarantined_at: { type: :string, nullable: true, summary: "Opts out of receiving emails" },
          send_welcome: { type: :boolean, nullable: true, summary: "Send a welcome email. Only used when subscribed_at is present." },
          photo: { type: :string, nullable: true }
        },
        required: [ "email" ]
      }
      response "201", "member created" do
        let(:member) { { name: "foo", email: "bar@example.com" } }
        run_test!
      end

      response "422", "invalid request" do
        let(:member) { { email: "" } }
        run_test!
      end

      response "409", "email already exists" do
        let(:existing_member) { community.members.create(name: "foo", email: "leonhard@example.com") }
        let(:member) { { email: existing_member.email } }
        run_test!
      end
    end
  end

  path "/members/{id}" do
    get "Retrieves a member" do
      security [ { api_key: [] } ]

      tags "Members"
      consumes "application/json"
      produces "application/json"
      parameter name: :id, in: :path, type: :string, description: "ID, slug, or url-encoded email of the member to retrieve"
      request_body_example value: { some_field: "Foo" }, name: "basic", summary: "Request example description"

      response "200", "member found" do
        schema type: :object,
          properties: {
            id: { type: :integer },
            email: { type: :string },
            name: { type: :string },
            about: { type: :string, nullable: true },
            permission: { type: :string },
            subscribed_at: { type: :boolean, nullable: true, summary: "Opts in to receive emails immediately" },
            quarantined_at: { type: :string, nullable: true, summary: "Opts out of receiving emails" },
            photo_url: { type: :string, nullable: true },
            created_at: { type: :string },
            updated_at: { type: :string },
            locked_at: { type: :string, nullable: true },
            status: { type: :string },
            slug: { type: :string }
          },
          required: [ "id" ]

        let(:id) { existing_member.id.to_s }
        run_test!
      end

      response "404", "member not found" do
        let(:id) { "invalid" }
        run_test!
      end
    end
  end

  path "/members" do
    get "Lists members" do
      security [ { api_key: [] } ]

      tags "Members"
      consumes "application/json"
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, description: "Page number"
      parameter name: :items, in: :query, type: :integer, description: "Number of items per page"

      response "200", "members found" do
        let(:community) { Community.create(name: "Test Community", email: "test@example.com") }

        schema type: :object,
          properties: {
            members: { type: :array, items: { type: :object, properties: { id: { type: :string }, email: { type: :string }, name: { type: :string }, about: { type: :string }, permission: { type: :string }, slug: { type: :string }, created_at: { type: :string }, updated_at: { type: :string }, quarantined_at: { type: :string, nullable: true }, subscribed_at: { type: :boolean, nullable: true }, photo_url: { type: :string, nullable: true }, status: { type: :string } } } },
            metadata: { type: :object, properties: { count: { type: :integer }, page: { type: :integer }, last: { type: :integer, nullable: true } } }
          },
          required: [ "members", "metadata" ]

        let(:page) { 1 }
        let(:items) { 10 }
        run_test!
      end
    end
  end

  path "/members/{id}" do
    put "Updates a member" do
      security [ { api_key: [] } ]

      tags "Members"
      consumes "application/json"
      produces "application/json"
      parameter name: :id, in: :path, type: :string, description: "Member ID, slug, or url-encoded email"
      parameter name: :member, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          photo: { type: :string },
          about: { type: :string },
          locked_at: { type: :string, nullable: true },
          quarantined_at: { type: :string, nullable: true }
        },
        required: []
      }
      response "200", "member updated" do
        let(:id) { existing_member.id.to_s }
        let(:member) { { name: "new name" } }
        run_test!
      end

      response "404", "member not found" do
        let(:id) { "invalid" }
        let(:member) { { name: "new name" } }
        run_test!
      end
    end
  end
end

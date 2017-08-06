describe BlocksController, :type => :controller do
  before do
    sign_in alice
  end

  describe "#create" do
    it "creates a block" do
      expect {
        post :create, format: :json, block: {person_id: eve.person.id}
      }.to change { alice.blocks.count }.by(1)
    end

    it "responds with 204" do
      post :create, format: :json, block: {person_id: eve.person.id}
      expect(response.status).to eq(204)
    end

    it "calls #disconnect_if_contact" do
      expect(@controller).to receive(:disconnect_if_contact).with(bob.person)
      post :create, format: :json, block: {person_id: bob.person.id}
    end
  end

  describe "#destroy" do
    before do
      @block = alice.blocks.create(:person => eve.person)
    end

    it "responds with 204" do
      delete :destroy, format: :json, id: @block.id
      expect(response.status).to eq(204)
    end

    it "removes a block" do
      expect {
        delete :destroy, format: :json, id: @block.id
      }.to change { alice.blocks.count }.by(-1)
    end
  end

  describe "#disconnect_if_contact" do
    before do
      allow(@controller).to receive(:current_user).and_return(alice)
    end

    it "calls disconnect with the force option if there is a contact for a given user" do
      contact = alice.contact_for(bob.person)
      allow(alice).to receive(:contact_for).and_return(contact)
      expect(alice).to receive(:disconnect).with(contact)
      @controller.send(:disconnect_if_contact, bob.person)
    end

    it "doesn't call disconnect if there is a contact for a given user" do
      expect(alice).not_to receive(:disconnect)
      @controller.send(:disconnect_if_contact, eve.person)
    end
  end
end

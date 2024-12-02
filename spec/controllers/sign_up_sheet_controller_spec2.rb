RSpec.describe SignUpSheetController, type: :controller do
  describe '#save_topic_deadlines' do
    let(:assignment) { create(:assignment, id: 1) }
    let(:topic) { create(:sign_up_topic, id: 1, assignment: assignment) }
    let(:submission_deadline_type) { create(:deadline_type, name: 'submission', id: 1) }
    let(:review_deadline_type) { create(:deadline_type, name: 'review', id: 2) }
    let(:due_date) { create(:assignment_due_date, parent_id: assignment.id, deadline_type: submission_deadline_type) }
    let(:due_date2) { create(:assignment_due_date, parent_id: assignment.id, deadline_type: review_deadline_type) }
    let(:topic_due_date) do
      create(
        :topic_due_date,
        parent_id: topic.id,
        deadline_type: submission_deadline_type,
        round: 1,
        due_at: '2024-12-02 23:59'
      )
    end

    before do
      allow(assignment).to receive(:num_review_rounds).and_return(1)
      assignment.due_dates = [due_date, due_date2]
      allow(SignUpTopic).to receive(:where).with(assignment_id: '1').and_return([topic])
      allow(TopicDueDate).to receive(:find_by).with(parent_id: 1, deadline_type_id: 1, round: 1).and_return(topic_due_date)
      allow_any_instance_of(TopicDueDate).to receive(:update).and_call_original
    end

    context 'when topic_due_date can be found' do
      it 'updates the existing topic_due_date record and redirects to assignment#edit page' do
        request_params = {
          assignment_id: 1,
          due_date: {
            '1_submission_1_due_date' => '2024-12-03 23:59',
            '1_review_1_due_date' => '2024-12-04 23:59'
          }
        }

        post :save_topic_deadlines, params: request_params

        expect(topic_due_date.reload.due_at.strftime('%Y-%m-%d %H:%M')).to eq('2024-12-03 23:59')
        expect(response).to redirect_to('/assignments/1/edit')
      end
    end
  end
end


require 'spec_helper'

describe WorkLauncher do
  class MyTestWorker < WorkerBase
    @perform_after = 10000.minutes
  end

  let (:work_data) { MyTestWorker.work_data }

  describe '.launch' do
    it 'finds the schedules the specified worker' do
      expect(MyTestWorker).to receive(:schedule)
      WorkLauncher.launch :my_test_worker, {}
    end
  end
end
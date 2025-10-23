require 'rails_helper'

RSpec.describe StorageInfo, type: :model do
  describe 'validations' do
    describe 'presence validations' do
      it 'validates presence of storage_type' do
        storage_info = StorageInfo.new(identifier: 'test-identifier')
        expect(storage_info).not_to be_valid
        expect(storage_info.errors[:storage_type]).to include("can't be blank")
      end

      it 'validates presence of identifier' do
        storage_info = StorageInfo.new(storage_type: 'cloud')
        expect(storage_info).not_to be_valid
        expect(storage_info.errors[:identifier]).to include("can't be blank")
      end

      it 'is valid when both storage_type and identifier are present' do
        storage_info = StorageInfo.new(storage_type: 'cloud', identifier: 'test-identifier')
        expect(storage_info).to be_valid
      end
    end

    describe 'storage_type inclusion validation' do
      it 'validates storage_type is included in allowed values' do
        storage_info = StorageInfo.new(storage_type: 'invalid_type', identifier: 'test-identifier')
        expect(storage_info).not_to be_valid
        expect(storage_info.errors[:storage_type]).to include('is not included in the list')
      end

      it 'accepts valid storage types' do
        valid_types = %w[cloud database file ftp]

        valid_types.each do |type|
          storage_info = StorageInfo.new(storage_type: type, identifier: "test-#{type}")
          expect(storage_info).to be_valid, "Expected #{type} to be valid"
        end
      end
    end
  end

  describe 'database constraints' do
    describe 'unique identifier constraint' do
      it 'prevents duplicate identifiers' do
        StorageInfo.create!(storage_type: 'cloud', identifier: 'unique-identifier')

        duplicate_storage_info = StorageInfo.new(storage_type: 'database', identifier: 'unique-identifier')
        expect { duplicate_storage_info.save! }.to raise_error(ActiveRecord::RecordNotUnique)
      end

      it 'allows different identifiers' do
        StorageInfo.create!(storage_type: 'cloud', identifier: 'first-identifier')

        second_storage_info = StorageInfo.new(storage_type: 'database', identifier: 'second-identifier')
        expect(second_storage_info).to be_valid
        expect(second_storage_info.save).to be true
      end
    end
  end

  describe 'model creation' do
    it 'creates a valid storage_info record' do
      storage_info = StorageInfo.create!(storage_type: 'cloud', identifier: 'test-identifier')

      expect(storage_info).to be_persisted
      expect(storage_info.storage_type).to eq('cloud')
      expect(storage_info.identifier).to eq('test-identifier')
      expect(storage_info.created_at).to be_present
      expect(storage_info.updated_at).to be_present
    end

    it 'updates timestamps on save' do
      storage_info = StorageInfo.create!(storage_type: 'file', identifier: 'timestamp-test')
      original_updated_at = storage_info.updated_at

      sleep(0.1) # Ensure time difference
      storage_info.update!(storage_type: 'database')

      expect(storage_info.updated_at).to be > original_updated_at
    end
  end

  describe 'key attribute' do
    describe 'automatic key generation' do
      it 'sets a key automatically for new records' do
        storage_info = StorageInfo.new(storage_type: 'cloud', identifier: 'test-identifier')
        expect(storage_info.key).to be_nil

        storage_info.valid?
        expect(storage_info.key).to be_present
        expect(storage_info.key).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
      end

      it 'sets a key when creating a record' do
        storage_info = StorageInfo.create!(storage_type: 'cloud', identifier: 'test-identifier')

        expect(storage_info.key).to be_present
        expect(storage_info.key).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
      end

      it 'does not override an existing key' do
        custom_key = 'custom-key-123'
        storage_info = StorageInfo.new(storage_type: 'cloud', identifier: 'test-identifier', key: custom_key)

        storage_info.valid?
        expect(storage_info.key).to eq(custom_key)
      end
    end

    describe 'key immutability' do
      it 'does not change the key implicitly during updates' do
        storage_info = StorageInfo.create!(storage_type: 'cloud', identifier: 'test-identifier')
        original_key = storage_info.key

        storage_info.update!(storage_type: 'database', identifier: 'updated-identifier')

        expect(storage_info.key).to eq(original_key)
      end

      it 'changes the key when updated explicitly' do
        storage_info = StorageInfo.create!(storage_type: 'cloud', identifier: 'test-identifier')
        original_key = storage_info.key

        storage_info.update!(key: 'new-key-attempt')

        expect(storage_info.key).to eq('new-key-attempt')
      end
    end

    describe 'key uniqueness' do
      it 'prevents duplicate keys' do
        StorageInfo.create!(storage_type: 'cloud', identifier: 'first-identifier', key: 'duplicate-key')

        duplicate_storage_info = StorageInfo.new(
          storage_type: 'database',
          identifier: 'second-identifier',
          key: 'duplicate-key'
        )
        expect { duplicate_storage_info.save! }.to raise_error(ActiveRecord::RecordNotUnique)
      end

      it 'allows different keys' do
        StorageInfo.create!(storage_type: 'cloud', identifier: 'first-identifier', key: 'first-key')

        second_storage_info = StorageInfo.new(
          storage_type: 'database',
          identifier: 'second-identifier',
          key: 'second-key'
        )
        expect(second_storage_info).to be_valid
        expect(second_storage_info.save).to be true
      end
    end
  end
end

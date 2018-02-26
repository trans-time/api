defmodule Api.ProfileTest do
  use Api.DataCase

  alias Api.Profile

  describe "user_profiles" do
    alias Api.Profile.UserProfile

    @valid_attrs %{description: "some description", post_count: 42, website: "some website"}
    @update_attrs %{description: "some updated description", post_count: 43, website: "some updated website"}
    @invalid_attrs %{description: nil, post_count: nil, website: nil}

    def user_profile_fixture(attrs \\ %{}) do
      {:ok, user_profile} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Profile.create_user_profile()

      user_profile
    end

    test "list_user_profiles/0 returns all user_profiles" do
      user_profile = user_profile_fixture()
      assert Profile.list_user_profiles() == [user_profile]
    end

    test "get_user_profile!/1 returns the user_profile with given id" do
      user_profile = user_profile_fixture()
      assert Profile.get_user_profile!(user_profile.id) == user_profile
    end

    test "create_user_profile/1 with valid data creates a user_profile" do
      assert {:ok, %UserProfile{} = user_profile} = Profile.create_user_profile(@valid_attrs)
      assert user_profile.description == "some description"
      assert user_profile.post_count == 42
      assert user_profile.website == "some website"
    end

    test "create_user_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Profile.create_user_profile(@invalid_attrs)
    end

    test "update_user_profile/2 with valid data updates the user_profile" do
      user_profile = user_profile_fixture()
      assert {:ok, user_profile} = Profile.update_user_profile(user_profile, @update_attrs)
      assert %UserProfile{} = user_profile
      assert user_profile.description == "some updated description"
      assert user_profile.post_count == 43
      assert user_profile.website == "some updated website"
    end

    test "update_user_profile/2 with invalid data returns error changeset" do
      user_profile = user_profile_fixture()
      assert {:error, %Ecto.Changeset{}} = Profile.update_user_profile(user_profile, @invalid_attrs)
      assert user_profile == Profile.get_user_profile!(user_profile.id)
    end

    test "delete_user_profile/1 deletes the user_profile" do
      user_profile = user_profile_fixture()
      assert {:ok, %UserProfile{}} = Profile.delete_user_profile(user_profile)
      assert_raise Ecto.NoResultsError, fn -> Profile.get_user_profile!(user_profile.id) end
    end

    test "change_user_profile/1 returns a user_profile changeset" do
      user_profile = user_profile_fixture()
      assert %Ecto.Changeset{} = Profile.change_user_profile(user_profile)
    end
  end

  describe "user_tag_summaries" do
    alias Api.Profile.UserTagSummary

    @valid_attrs %{summary: %{}}
    @update_attrs %{summary: %{}}
    @invalid_attrs %{summary: nil}

    def user_tag_summary_fixture(attrs \\ %{}) do
      {:ok, user_tag_summary} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Profile.create_user_tag_summary()

      user_tag_summary
    end

    test "list_user_tag_summaries/0 returns all user_tag_summaries" do
      user_tag_summary = user_tag_summary_fixture()
      assert Profile.list_user_tag_summaries() == [user_tag_summary]
    end

    test "get_user_tag_summary!/1 returns the user_tag_summary with given id" do
      user_tag_summary = user_tag_summary_fixture()
      assert Profile.get_user_tag_summary!(user_tag_summary.id) == user_tag_summary
    end

    test "create_user_tag_summary/1 with valid data creates a user_tag_summary" do
      assert {:ok, %UserTagSummary{} = user_tag_summary} = Profile.create_user_tag_summary(@valid_attrs)
      assert user_tag_summary.summary == %{}
    end

    test "create_user_tag_summary/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Profile.create_user_tag_summary(@invalid_attrs)
    end

    test "update_user_tag_summary/2 with valid data updates the user_tag_summary" do
      user_tag_summary = user_tag_summary_fixture()
      assert {:ok, user_tag_summary} = Profile.update_user_tag_summary(user_tag_summary, @update_attrs)
      assert %UserTagSummary{} = user_tag_summary
      assert user_tag_summary.summary == %{}
    end

    test "update_user_tag_summary/2 with invalid data returns error changeset" do
      user_tag_summary = user_tag_summary_fixture()
      assert {:error, %Ecto.Changeset{}} = Profile.update_user_tag_summary(user_tag_summary, @invalid_attrs)
      assert user_tag_summary == Profile.get_user_tag_summary!(user_tag_summary.id)
    end

    test "delete_user_tag_summary/1 deletes the user_tag_summary" do
      user_tag_summary = user_tag_summary_fixture()
      assert {:ok, %UserTagSummary{}} = Profile.delete_user_tag_summary(user_tag_summary)
      assert_raise Ecto.NoResultsError, fn -> Profile.get_user_tag_summary!(user_tag_summary.id) end
    end

    test "change_user_tag_summary/1 returns a user_tag_summary changeset" do
      user_tag_summary = user_tag_summary_fixture()
      assert %Ecto.Changeset{} = Profile.change_user_tag_summary(user_tag_summary)
    end
  end

  describe "identities" do
    alias Api.Profile.Identity

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def identity_fixture(attrs \\ %{}) do
      {:ok, identity} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Profile.create_identity()

      identity
    end

    test "list_identities/0 returns all identities" do
      identity = identity_fixture()
      assert Profile.list_identities() == [identity]
    end

    test "get_identity!/1 returns the identity with given id" do
      identity = identity_fixture()
      assert Profile.get_identity!(identity.id) == identity
    end

    test "create_identity/1 with valid data creates a identity" do
      assert {:ok, %Identity{} = identity} = Profile.create_identity(@valid_attrs)
      assert identity.name == "some name"
    end

    test "create_identity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Profile.create_identity(@invalid_attrs)
    end

    test "update_identity/2 with valid data updates the identity" do
      identity = identity_fixture()
      assert {:ok, identity} = Profile.update_identity(identity, @update_attrs)
      assert %Identity{} = identity
      assert identity.name == "some updated name"
    end

    test "update_identity/2 with invalid data returns error changeset" do
      identity = identity_fixture()
      assert {:error, %Ecto.Changeset{}} = Profile.update_identity(identity, @invalid_attrs)
      assert identity == Profile.get_identity!(identity.id)
    end

    test "delete_identity/1 deletes the identity" do
      identity = identity_fixture()
      assert {:ok, %Identity{}} = Profile.delete_identity(identity)
      assert_raise Ecto.NoResultsError, fn -> Profile.get_identity!(identity.id) end
    end

    test "change_identity/1 returns a identity changeset" do
      identity = identity_fixture()
      assert %Ecto.Changeset{} = Profile.change_identity(identity)
    end
  end

  describe "user_identities" do
    alias Api.Profile.UserIdentity

    @valid_attrs %{end_date: "2010-04-17 14:00:00.000000Z", start_date: "2010-04-17 14:00:00.000000Z"}
    @update_attrs %{end_date: "2011-05-18 15:01:01.000000Z", start_date: "2011-05-18 15:01:01.000000Z"}
    @invalid_attrs %{end_date: nil, start_date: nil}

    def user_identity_fixture(attrs \\ %{}) do
      {:ok, user_identity} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Profile.create_user_identity()

      user_identity
    end

    test "list_user_identities/0 returns all user_identities" do
      user_identity = user_identity_fixture()
      assert Profile.list_user_identities() == [user_identity]
    end

    test "get_user_identity!/1 returns the user_identity with given id" do
      user_identity = user_identity_fixture()
      assert Profile.get_user_identity!(user_identity.id) == user_identity
    end

    test "create_user_identity/1 with valid data creates a user_identity" do
      assert {:ok, %UserIdentity{} = user_identity} = Profile.create_user_identity(@valid_attrs)
      assert user_identity.end_date == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert user_identity.start_date == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
    end

    test "create_user_identity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Profile.create_user_identity(@invalid_attrs)
    end

    test "update_user_identity/2 with valid data updates the user_identity" do
      user_identity = user_identity_fixture()
      assert {:ok, user_identity} = Profile.update_user_identity(user_identity, @update_attrs)
      assert %UserIdentity{} = user_identity
      assert user_identity.end_date == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert user_identity.start_date == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
    end

    test "update_user_identity/2 with invalid data returns error changeset" do
      user_identity = user_identity_fixture()
      assert {:error, %Ecto.Changeset{}} = Profile.update_user_identity(user_identity, @invalid_attrs)
      assert user_identity == Profile.get_user_identity!(user_identity.id)
    end

    test "delete_user_identity/1 deletes the user_identity" do
      user_identity = user_identity_fixture()
      assert {:ok, %UserIdentity{}} = Profile.delete_user_identity(user_identity)
      assert_raise Ecto.NoResultsError, fn -> Profile.get_user_identity!(user_identity.id) end
    end

    test "change_user_identity/1 returns a user_identity changeset" do
      user_identity = user_identity_fixture()
      assert %Ecto.Changeset{} = Profile.change_user_identity(user_identity)
    end
  end
end

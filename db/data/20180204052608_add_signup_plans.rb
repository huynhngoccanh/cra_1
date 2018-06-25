class AddSignupPlans < SeedMigration::Migration
  def up
    SignupStripePlan.destroy_all
    SignupStripePlan.find_or_create_by(name: "Monthly (10$/month)",
      amount: 1000,
      currency: "usd",
      interval: "month",
      interval_count: 1,
      plan_id: "cz_monthly"
    )

    SignupStripePlan.find_or_create_by(name: "Yearly (59$/year)",
      amount: 5900,
      currency: "usd",
      interval: "year",
      interval_count: 1,
      plan_id: "cz_yearly"
    )
  end

  def down
  end
end

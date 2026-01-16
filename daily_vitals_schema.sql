-- Add Daily Vitals Log Table
CREATE TABLE IF NOT EXISTS daily_vitals_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  log_date TIMESTAMPTZ NOT NULL,
  stress_level INTEGER CHECK (stress_level BETWEEN 1 AND 10),
  mood TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(user_id, log_date)
);

ALTER TABLE daily_vitals_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY daily_vitals_policy
ON daily_vitals_log FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

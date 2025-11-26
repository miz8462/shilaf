import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Firebase Admin SDKのアクセストークンを取得する関数
async function getAccessToken(): Promise<string> {
  // Firebase Admin SDKのサービスアカウントキーを使用
  const serviceAccount = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT') ?? '{}')

  const jwtHeader = btoa(JSON.stringify({ alg: 'RS256', typ: 'JWT' }))
  const now = Math.floor(Date.now() / 1000)
  const jwtClaimSet = btoa(JSON.stringify({
    iss: serviceAccount.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  }))

  // 実際の実装ではRS256署名が必要
  // 簡易版としてFirebase Admin Node.js SDKの使用を推奨
  return 'YOUR_ACCESS_TOKEN' // 後述の方法で取得
}

serve(async (req) => {
  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // 現在時刻を取得(分単位で丸める)
    const now = new Date()
    const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`
    const currentDay = now.getDay()

    console.log(`Checking reminders for ${currentTime}, day ${currentDay}`)

    // 送信すべきリマインダーを取得
    const { data: reminders, error } = await supabase
      .from('reminders')
      .select(`
        *,
        user_tokens!inner(fcm_token)
      `)
      .eq('is_active', true)
      .contains('days_of_week', [currentDay])
      .like('remind_at', `${currentTime}%`)

    if (error) {
      console.error('Error fetching reminders:', error)
      throw error
    }

    console.log(`Found ${reminders?.length || 0} reminders to send`)

    // FCMで通知を送信
    const results = []
    for (const reminder of reminders || []) {
      try {
        const response = await fetch(
          `https://fcm.googleapis.com/v1/projects/${Deno.env.get('FIREBASE_PROJECT_ID')}/messages:send`,
          {
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${Deno.env.get('FIREBASE_ACCESS_TOKEN')}`,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              message: {
                token: reminder.user_tokens.fcm_token,
                notification: {
                  title: reminder.title,
                  body: reminder.message || '',
                },
                webpush: {
                  fcm_options: {
                    link: Deno.env.get('APP_URL') || 'https://your-app-url.com'
                  }
                }
              }
            })
          }
        )

        const result = await response.json()
        results.push({ reminder_id: reminder.id, success: response.ok, result })
        console.log(`Sent notification for reminder ${reminder.id}:`, result)
      } catch (err) {
        console.error(`Failed to send notification for reminder ${reminder.id}:`, err)
        results.push({ reminder_id: reminder.id, success: false, error: err.message })
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        sent: results.length,
        results
      }),
      {
        headers: { 'Content-Type': 'application/json' },
      }
    )
  } catch (err) {
    console.error('Function error:', err)
    return new Response(
      JSON.stringify({ success: false, error: err.message }),
      {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      }
    )
  }
})
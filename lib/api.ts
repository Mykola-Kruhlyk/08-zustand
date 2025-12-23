import axios from 'axios';

export const API_BASE_URL = 'https://notehub-public.goit.study/api';

export const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    Authorization: `Bearer ${process.env.NEXT_PUBLIC_NOTEHUB_TOKEN}`,
  },
});

export interface Note {
  id: number;
  title: string;
  content: string;
  tags: string[];
}

export async function fetchNotes({
  page = 1,
  perPage = 12,
  tag,
}: {
  page?: number;
  perPage?: number;
  tag?: string;
}): Promise<Note[]> {
  try {
    const query = tag ? `?tag=${tag}&page=${page}&perPage=${perPage}` : `?page=${page}&perPage=${perPage}`;
    const { data } = await api.get<Note[]>(`/notes${query}`);
    return data;
  } catch (error) {
    console.error('Error fetching notes:', error);
    return []; // fallback, щоб SSR не падав
  }
}
